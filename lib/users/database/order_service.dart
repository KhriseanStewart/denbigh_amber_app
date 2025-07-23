import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/model/orders.dart';
import 'package:denbigh_app/farmers/services/sales_order.services.dart';
import 'package:denbigh_app/utils/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  final uuid = Uuid().v4();

  /// Create orders from user's cart items
  /// Groups items by farmerId and creates separate orders for each farmer
  Future<bool> createOrderFromCart(String userId) async {
    try {
      // Fetch all cart items for the user
      final cartSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .get();

      if (cartSnapshot.docs.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Group items by farmerId
      Map<String, List<QueryDocumentSnapshot>> itemsByFarmer = {};
      for (var cartItem in cartSnapshot.docs) {
        final data = cartItem.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final farmerId = data['farmerId'] ?? 'unknown';

        if (!itemsByFarmer.containsKey(farmerId)) {
          itemsByFarmer[farmerId] = [];
        }
        itemsByFarmer[farmerId]!.add(cartItem);
      }

      // Prepare a map to hold productId and total ordered quantity for stock update
      Map<String, int> productQuantities = {};

      // For each farmer, create an order
      for (var entry in itemsByFarmer.entries) {
        final farmerId = entry.key;
        final farmerItems = entry.value;

        double totalPrice = 0;
        List<Map<String, dynamic>> orderItems = [];

        for (var cartItem in farmerItems) {
          final data = cartItem.data() as Map<String, dynamic>;
          final productId = data['productId'];
          final int quantity = data['customerQuantity'] ?? 1;
          final price = (data['price'] as num).toDouble();

          totalPrice += price * quantity;

          orderItems.add({
            'productId': productId,
            'name': data['name'],
            'quantity': quantity,
            'price': price,
            'category': data['category'],
            'unitType': data['unitType'],
            'imageUrl': data['imageUrl'],
            'farmerId': farmerId,
          });
          // await createReceipt(orderId)

          final hasStock = await calculateStock(productId, quantity);
          if (hasStock == false) {
            Exception("Insufficent");
            return false;
          }
        }

        // Create order for this farmer
        await _createOrderForFarmer(userId, farmerId, farmerItems);

        // Optionally, create receipt here if needed
      }

      // Clear the cart after stock update
      await _clearCart(userId);

      return true;
    } catch (e) {
      print('Error creating order from cart: $e');
      return false;
    }
  }

  Future<bool> calculateStock(String productId, int prevStock) async {
    final productdb = await _db.collection('products').doc(productId).get();
    print("product ID: $productId");
    final data = await productdb.data();
    final stock = data!['stock'];
    print(stock);
    if (stock <= 0) {
      print("object");
      Exception("Error ");
      return false;
    } else {
      int newStock = stock - prevStock;
      await _db.collection('products').doc(productId).update({
        'stock': newStock,
      });
      print(newStock);
      return true;
    }
  }

  /// Create a receipt for the user after order placement
  Future<void> createReceipt(String orderId) async {
    try {
      final orderRef = _db.collection('orders').doc(orderId);
      final orderSnapshot = await orderRef.get();

      if (!orderSnapshot.exists) {
        throw Exception('Order not found');
      }

      final orderData = orderSnapshot.data()!;
      final customerId = orderData['customerId'];

      final receiptData = {
        'orderId': orderId,
        'customerId': customerId,
        'items': orderData['items'],
        'totalPrice': orderData['totalPrice'],
        'date': FieldValue.serverTimestamp(),
        'status': 'completed',
      };

      // Save receipt to Firestore under 'receipts' collection
      await _db.collection('receipts').add(receiptData);

      print('Receipt created successfully for order: $orderId');
    } catch (e) {
      print('Failed to create receipt: $e');
    }
  }

  /// Create a single order for one farmer
  Future<void> _createOrderForFarmer(
    String customerId,
    String farmerId,
    List<QueryDocumentSnapshot> cartItems,
  ) async {
    double totalPrice = 0;
    List<Map<String, dynamic>> orderItems = [];
    final orderId = uuid;

    // Convert cart items to order items
    for (var cartItem in cartItems) {
      final data = cartItem.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final quantity = data['customerQuantity'] ?? 1;
      final price = (data['price'] as num).toDouble();
      final itemTotal = price * quantity;
      totalPrice += itemTotal;

      orderItems.add({
        'productId': data['productId'],
        'name': data['name'],
        'description': data['description'] ?? '',
        'price': price,
        'quantity': quantity,
        'unit': data['unitType'] ?? 'piece',
        'imageUrl': data['imageUrl'] ?? '',
        'customerLocation': data['location'] ?? '',
        'farmerId': farmerId,
        'orderId': '',
      });
    }

    // Create the order document
    final orderData = {
      'orderId': '',
      'customerId': customerId,
      'farmerId': farmerId,
      'items': orderItems,
      'totalPrice': totalPrice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'name': orderItems.isNotEmpty ? orderItems.first['name'] : '',
      'unit': orderItems.isNotEmpty ? orderItems.first['unit'] : '',
      'quantity': orderItems.length.toString(),
      'customerLocation': orderItems.isNotEmpty
          ? orderItems.first['customerLocation']
          : '',
    };

    // Add order to Firestore
    // Add order to Firestore
    final docRef = await _db.collection('orders').add(orderData);
    List<OrderItem> orderItemList = orderItems.map((item) {
      return OrderItem(
        orderId: orderId,
        productId:
            item['productId'] ?? 'DEFAULT_PRODUCT_ID', // or other default
        name: item['name'],
        quantity: item['quantity'] ?? 1,
        price: item['price'] ?? 0.0,
        unit: item['unit'] ?? 'unit',
        farmerId: farmerId,
        customerLocation: "customerLocation", // or pass as parameter
      );
    }).toList();

    await SalesAndOrdersService().createOrder(
      Orderlist(
        orderId: orderId,
        name: orderItems.first['name'],
        unit: orderItems.first['unit'],
        quantity: orderItems.length.toString(),
        customerId: customerId,
        farmerId: farmerId,
        items: orderItemList,
        totalPrice: totalPrice,
        status: 'processing',
        createdAt: DateTime.now(),
        customerLocation: '',
      ),
    );

    // Update with the actual order ID
    await docRef.update({
      'orderId': docRef.id,
      'items': orderItems.map((item) {
        item['orderId'] = docRef.id;
        return item;
      }).toList(),
    });

    // Send notification to farmer about new order
    try {
      await _notificationService.notifyFarmerNewOrder(
        farmerId: farmerId,
        orderId: docRef.id,
        customerName: 'Customer', // You might want to get actual customer name
        totalAmount: totalPrice,
        itemCount: orderItems.length,
      );
    } catch (e) {
      print('Failed to send notification: $e');
      // Don't fail the order creation if notification fails
    }
  }

  /// Clear user's cart after successful order creation
  Future<void> _clearCart(String userId) async {
    final cartRef = _db.collection('users').doc(userId).collection('cartItems');

    final cartSnapshot = await cartRef.get();

    // Delete all cart items
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Get orders for a specific customer

  /// Get orders for a specific customer
  Stream<List<Map<String, dynamic>>> getOrdersForCustomer(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Get order details to send notification
    try {
      final orderDoc = await _db.collection('orders').doc(orderId).get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data();
        if (orderData != null) {
          final customerId = orderData['customerId'];
          if (customerId != null) {
            await _notificationService.notifyCustomerOrderUpdate(
              customerId: customerId,
              orderId: orderId,
              newStatus: newStatus,
            );
          }
        }
      }
    } catch (e) {
      print('Failed to send status update notification: $e');
      // Don't fail the status update if notification fails
    }
  }

  /// Cancel an order (only if status is 'pending')
  Future<bool> cancelOrder(String orderId) async {
    try {
      final orderDoc = await _db.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final orderData = orderDoc.data();
      if (orderData == null) {
        throw Exception('Order data not found');
      }

      final status = orderData['status'];

      if (status != 'pending') {
        throw Exception('Cannot cancel order with status: $status');
      }

      await updateOrderStatus(orderId, 'cancelled');
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }
}
