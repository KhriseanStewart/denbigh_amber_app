import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/utils/services/notification_service.dart';
import 'package:rxdart/rxdart.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  /// Create orders from user's cart items - SIMPLIFIED
  Future<bool> createOrderFromCart(String userId) async {
    try {
      // Get cart items
      final cartSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .get();

      if (cartSnapshot.docs.isEmpty) {
        print('Cart is empty');
        return false;
      }

      // Group items by farmerId
      Map<String, List<QueryDocumentSnapshot>> itemsByFarmer = {};
      for (var cartItem in cartSnapshot.docs) {
        final data = cartItem.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final farmerId = data['farmerId'] ?? 'unknown';
        print('DEBUG: Cart item farmerId: $farmerId');
        print('DEBUG: Cart item data: $data');
        if (!itemsByFarmer.containsKey(farmerId)) {
          itemsByFarmer[farmerId] = [];
        }
        itemsByFarmer[farmerId]!.add(cartItem);
      }

      // Create order for each farmer
      for (var entry in itemsByFarmer.entries) {
        final farmerId = entry.key;
        final farmerItems = entry.value;
        await _createOrderForFarmer(userId, farmerId, farmerItems);
      }

      // Clear cart
      await _clearCart(userId);
      print('Orders created successfully');
      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<bool> calculateStock(String productId, int prevStock) async {
    final productdb = await _db.collection('products').doc(productId).get();
    print("product ID: $productId");
    final data = productdb.data();
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

  Future<void> _createOrderForFarmer(
    String customerId,
    String farmerId,
    List<QueryDocumentSnapshot> cartItems,
  ) async {
    int totalPrice = 0;
    List<Map<String, dynamic>> orderItems = [];

    // Convert cart items to order items
    for (var cartItem in cartItems) {
      final data = cartItem.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final quantity = data['customerQuantity'] ?? 1;
      final price = (data['price'] as num).toInt();
      totalPrice += (price * quantity).toInt();

      orderItems.add({
        'productId': data['productId'],
        'name': data['name'],
        'price': price,
        'quantity': quantity,
        'unit': data['unitType'] ?? 'piece',
        'imageUrl': data['imageUrl'] ?? '',
      });
    }

    // Simple order data
    final orderData = {
      'customerId': customerId,
      'farmerId': farmerId,
      'items': orderItems,
      'totalPrice': totalPrice,
      'status': 'Processing',
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add to main orders collection
    await _db.collection('orders').add(orderData);
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

  /// Get combined orders and sales data for a customer (shows complete order history)
  Stream<List<Map<String, dynamic>>> showOrdersForCustomer(String customerId) {
    // Combine orders and sales streams
    return Rx.combineLatest2(
      // Get current orders
      _db
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .snapshots(),
      // Get sales (completed orders)
      _db
          .collection('sales')
          .where('customerId', isEqualTo: customerId)
          .snapshots(),
      (QuerySnapshot ordersSnapshot, QuerySnapshot salesSnapshot) {
        List<Map<String, dynamic>> combinedData = [];

        // Add current orders
        for (var doc in ordersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            combinedData.add({
              'id': doc.id,
              'type': 'order',
              'orderId': doc.id,
              'status': data['status']?.toString() ?? 'processing',
              'createdAt': data['createdAt'],
              'totalPrice': data['totalPrice'],
              'items': data['items'],
              'imageUrl': data['imageUrl'],
              'farmerId': data['farmerId'],
              'customerName': data['customerName'],
              'customerLocation': data['customerLocation'],
            });
          }
        }

        // Add sales (completed orders) - group by orderId
        Map<String, List<Map<String, dynamic>>> salesByOrderId = {};
        for (var doc in salesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final orderId = data['orderId']?.toString();
            if (orderId != null && orderId.isNotEmpty) {
              if (!salesByOrderId.containsKey(orderId)) {
                salesByOrderId[orderId] = [];
              }
              salesByOrderId[orderId]!.add({
                'salesId': doc.id,
                'productId': data['productId'],
                'name': data['name'],
                'quantity': data['quantity'],
                'price':
                    data['totalPrice'], // totalPrice in sales is for the item
                'unit': data['unit'],
                'imageUrl': data['imageUrl'],
                'date': data['date'],
              });
            }
          }
        }

        // Convert grouped sales back to order format
        for (var entry in salesByOrderId.entries) {
          final orderId = entry.key;
          final salesItems = entry.value;

          if (salesItems.isNotEmpty) {
            final firstSale = salesItems.first;
            final totalPrice = salesItems.fold<int>(
              0,
              (sum, item) => sum + ((item['price'] as num?)?.toInt() ?? 0),
            );

            combinedData.add({
              'id': orderId,
              'type': 'sale',
              'orderId': orderId,
              'status': 'completed',
              'createdAt': salesItems.first['date'] ?? Timestamp.now(),
              'totalPrice': totalPrice,
              'items': salesItems
                  .map(
                    (sale) => {
                      'name': sale['name'],
                      'quantity': sale['quantity'],
                      'price': sale['price'],
                      'unit': sale['unit'],
                      'productId': sale['productId'],
                    },
                  )
                  .toList(),
              'imageUrl': firstSale['imageUrl'],
              'farmerId': '', // Not stored in sales
              'customerName': '', // Not needed for user view
              'customerLocation': '', // Not needed for user view
            });
          }
        }

        // Sort by creation date (most recent first)
        combinedData.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return combinedData;
      },
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

  /// Cancel an order (only if status is 'Processing')
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

      if (status != 'Processing') {
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
