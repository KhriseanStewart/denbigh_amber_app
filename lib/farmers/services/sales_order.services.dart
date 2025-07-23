import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/model/orders.dart' as model_orders;

import 'package:denbigh_app/farmers/model/sales.dart';

class SalesAndOrdersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ------------------- SALES METHODS -------------------

  Stream<List<Sale>> getSalesForProduct(String productId, String farmerId) {
    return _db
        .collection('sales')
        .where('productId', isEqualTo: productId)
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Sale.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<Sale>> getSalesForFarmer(String farmerId) {
    return _db
        .collection('sales')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Sale.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> recordSale(Sale sale) async {
    final docRef = await _db.collection('sales').add(sale.toMap());
    await docRef.update({'salesId': docRef.id});

    // Auto-update product statistics when sale is recorded
    await _updateProductFromSale(sale);
  }

  // Helper method to update product statistics when a sale is recorded
  Future<void> _updateProductFromSale(Sale sale) async {
    try {
      final productDoc = await _db
          .collection('products')
          .doc(sale.productId)
          .get();

      if (productDoc.exists) {
        final data = productDoc.data()!;
        final currentStock = data['stock'] ?? 0;
        final currentTotalSold = data['totalSold'] ?? 0;
        final currentTotalEarnings =
            (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;

        await _db.collection('products').doc(sale.productId).update({
          'stock': currentStock - sale.quantity,
          'totalSold': currentTotalSold + sale.quantity,
          'totalEarnings': currentTotalEarnings + sale.totalPrice,
        });
      }
    } catch (e) {
      print('Error updating product from sale: $e');
    }
  }

  // Method to convert order to sale and update product automatically
  Future<void> convertOrderToSale(String orderId) async {
    try {
      // Get the order
      final orderDoc = await _db.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) return;

      final order = model_orders.Orderlist.fromMap(
        orderDoc.data()!,
        orderDoc.id,
      );

      // Create sales for each item in the order
      for (final item in order.items) {
        final sale = Sale(
          salesId: '',
          productId: item.productId,
          farmerId: order.farmerId,
          customerId: order.customerId,
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          totalPrice: item.price * item.quantity,
          date: Timestamp.now(),
        );

        // Record the sale (this will also update the product)
        await recordSale(sale);
      }

      // Update order status to completed
      await _db.collection('orders').doc(orderId).update({
        'status': 'completed',
      });
    } catch (e) {
      print('Error converting order to sale: $e');
    }
  }

  // ------------------- ORDERS METHODS -------------------

Stream<List<model_orders.Orderlist>> getFilteredOrdersForFarmerManual(
    String farmerId,
  ) {
    return _db.collection('orders').snapshots().map((snapshot) {
      // Filter documents manually
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['farmerId'] == farmerId; // Check each document's farmerId
      }).toList();

      // Convert documents to your model
      return filteredDocs
          .map((doc) => model_orders.Orderlist.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<model_orders.Orderlist>> getOrdersForCustomer(String customerId) {
    return _db
        .collection('customers')
        .doc(customerId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => model_orders.Orderlist.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createOrder(model_orders.Orderlist order) async {
    // Create the order document in Firestore
    final docRef = await _db.collection('orders').add(order.toMap());

    // Update the document with the actual orderId
    await docRef.update({'orderId': docRef.id});

    // Also update the orderId in each item if they have orderId field
    final orderData = order.toMap();
    if (orderData['items'] != null && orderData['items'] is List) {
      final List<dynamic> items = orderData['items'];
      for (int i = 0; i < items.length; i++) {
        if (items[i] is Map<String, dynamic> &&
            items[i].containsKey('orderId')) {
          items[i]['orderId'] = docRef.id;
        }
      }
      // Update the items with the correct orderId
      await docRef.update({'items': items});
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  /// Increase the quantity of a specific product in an order.
  Future<void> increaseOrderItemQty(String orderId, String productId) async {
    final docRef = _db.collection('orders').doc(orderId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;
    final data = docSnap.data()!;
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final itemIndex = items.indexWhere(
      (item) => item['productId'] == productId,
    );
    if (itemIndex != -1) {
      items[itemIndex]['quantity'] = (items[itemIndex]['quantity'] ?? 1) + 1;
      await docRef.update({'items': items});
    }
  }

  /// Decrease the quantity of a specific product in an order.
  /// Removes the item if quantity goes to 0.
  Future<void> decreaseOrderItemQty(String orderId, String productId) async {
    final docRef = _db.collection('orders').doc(orderId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;
    final data = docSnap.data()!;
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final itemIndex = items.indexWhere(
      (item) => item['productId'] == productId,
    );
    if (itemIndex != -1) {
      int currentQty = items[itemIndex]['quantity'] ?? 1;
      if (currentQty > 1) {
        items[itemIndex]['quantity'] = currentQty - 1;
      } else {
        // Remove the item if qty is 1 and we're decreasing
        items.removeAt(itemIndex);
      }
      await docRef.update({'items': items});
    }
  }
}
