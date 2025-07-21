import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/utils/services/notification_service.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  /// Create orders from user's cart items
  /// Groups items by farmerId and creates separate orders for each farmer
  Future<bool> createOrderFromCart(String userId) async {
    try {
      // Get current user's cart items
      final cartSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .get();

      if (cartSnapshot.docs.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Group cart items by farmerId
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

      // Create separate orders for each farmer
      for (var entry in itemsByFarmer.entries) {
        final farmerId = entry.key;
        final farmerItems = entry.value;

        await _createOrderForFarmer(userId, farmerId, farmerItems);
      }

      // Clear the cart after successful order creation
      await _clearCart(userId);

      return true;
    } catch (e) {
      print('Error creating order from cart: $e');
      return false;
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
        'farmerId': farmerId, // Add farmerId to each item
        'orderId': '', // Will be set after creation
      });
    }

    // Create the order document
    final orderData = {
      'orderId': '', // Will be updated after creation
      'customerId': customerId,
      'farmerId': farmerId,
      'items': orderItems,
      'totalPrice': totalPrice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // Add fields expected by farmer model
      'name': orderItems.isNotEmpty ? orderItems.first['name'] : '',
      'unit': orderItems.isNotEmpty ? orderItems.first['unit'] : '',
      'quantity': orderItems.length.toString(),
      'customerLocation': orderItems.isNotEmpty
          ? orderItems.first['customerLocation']
          : '',
    };

    // Add order to Firestore
    final docRef = await _db.collection('orders').add(orderData);

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
