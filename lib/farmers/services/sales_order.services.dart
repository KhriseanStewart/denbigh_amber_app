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
          (snapshot) => snapshot.docs.map((doc) {
            try {
              return Sale.fromMap(doc.data(), doc.id);
            } catch (e) {
              print('Error parsing sale document ${doc.id}: $e');
              print('Document data: ${doc.data()}');
              // Return a default sale or null, filter out nulls later
              rethrow;
            }
          }).toList(),
        );
  }

  Stream<List<SalesGroup>> getMultiSalesForFarmer(String farmerId) {
    return _db
        .collection('sales')
        .where('farmerId', isEqualTo: farmerId)
        // Remove orderBy to avoid index requirement - we'll sort in memory
        .snapshots()
        .map((snapshot) {
          // Group sales by orderId (like the customer method does)
          final Map<String, List<Sale>> groupedSales = {};

          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();

              // Check if this is a consolidated sale (has 'items' array) or individual sale
              if (data.containsKey('items') && data['items'] is List) {
                // This is a consolidated sale - use orderId for grouping (like customer method)
                final items = data['items'] as List<dynamic>;
                final orderId = data['orderId']?.toString() ?? doc.id;

                // Create individual Sale objects from the items array
                for (var item in items) {
                  final sale = Sale(
                    salesId: doc.id,
                    productId: item['productId']?.toString() ?? '',
                    name: item['name']?.toString() ?? '',
                    quantity: (item['quantity'] as num?)?.toInt() ?? 0,
                    totalPrice:
                        ((item['price'] as num? ?? 0) *
                                (item['quantity'] as num? ?? 1))
                            .toInt(),
                    date:
                        data['date'] as Timestamp? ??
                        data['createdAt'] as Timestamp? ??
                        Timestamp.now(),
                    customerId: data['customerId']?.toString() ?? '',
                    customerName:
                        data['customerName']?.toString() ?? 'Unknown Customer',
                    farmerId: data['farmerId']?.toString() ?? '',
                    unit: item['unit']?.toString() ?? '',
                    orderSessionId: orderId, // Use orderId for consistency
                    customerLocation:
                        data['customerLocation']?.toString() ?? '',
                  );

                  if (!groupedSales.containsKey(orderId)) {
                    groupedSales[orderId] = [];
                  }
                  groupedSales[orderId]!.add(sale);
                }
              } else {
                // This is an old individual sale - handle normally
                final sessionId = data['orderSessionId']?.toString();
                final sale = Sale.fromMap(data, doc.id);

                final groupKey = sessionId?.isNotEmpty == true
                    ? sessionId!
                    : doc.id;

                if (!groupedSales.containsKey(groupKey)) {
                  groupedSales[groupKey] = [];
                }
                groupedSales[groupKey]!.add(sale);
              }
            } catch (e) {
              print('Error parsing sale document ${doc.id}: $e');
              continue;
            }
          }

          // Convert grouped sales to SalesGroup objects
          final List<SalesGroup> result = [];
          for (final salesGroup in groupedSales.values) {
            if (salesGroup.isNotEmpty) {
              try {
                result.add(SalesGroup.fromSales(salesGroup));
              } catch (e) {
                print('Error creating SalesGroup: $e');
                continue;
              }
            }
          }

          // Sort by date descending
          result.sort((a, b) => b.date.compareTo(a.date));

          return result;
        });
  }

  /// Alternative method for getting sales without complex queries
  Stream<List<SalesGroup>> getSimpleSalesForFarmer(String farmerId) {
    return _db.collection('sales').where('farmerId', isEqualTo: farmerId).snapshots().map((
      snapshot,
    ) {
      print(
        'DEBUG: Found ${snapshot.docs.length} sales documents for farmer $farmerId',
      );

      // Group sales by orderId or orderSessionId
      final Map<String, List<Sale>> groupedSales = {};

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          print('DEBUG: Processing sale document ${doc.id}');

          // Check if this is a consolidated sale (has 'items' array) or individual sale
          if (data.containsKey('items') && data['items'] is List) {
            print(
              'DEBUG: Found consolidated sale with ${(data['items'] as List).length} items',
            );
            // This is a consolidated sale - use orderId for grouping
            final items = data['items'] as List<dynamic>;
            final orderId = data['orderId']?.toString() ?? doc.id;

            // Create individual Sale objects from the items array
            for (var item in items) {
              final sale = Sale(
                salesId: doc.id,
                productId: item['productId']?.toString() ?? '',
                name: item['name']?.toString() ?? '',
                quantity: (item['quantity'] as num?)?.toInt() ?? 0,
                totalPrice:
                    ((item['price'] as num? ?? 0) *
                            (item['quantity'] as num? ?? 1))
                        .toInt(),
                date:
                    data['date'] as Timestamp? ??
                    data['createdAt'] as Timestamp? ??
                    Timestamp.now(),
                customerId: data['customerId']?.toString() ?? '',
                customerName:
                    data['customerName']?.toString() ?? 'Unknown Customer',
                farmerId: data['farmerId']?.toString() ?? '',
                unit: item['unit']?.toString() ?? '',
                orderSessionId: orderId,
                customerLocation: data['customerLocation']?.toString() ?? '',
              );

              if (!groupedSales.containsKey(orderId)) {
                groupedSales[orderId] = [];
              }
              groupedSales[orderId]!.add(sale);
            }
          } else {
            print('DEBUG: Found individual sale');
            // This is an old individual sale - handle normally
            final sessionId = data['orderSessionId']?.toString();
            final sale = Sale.fromMap(data, doc.id);

            final groupKey = sessionId?.isNotEmpty == true
                ? sessionId!
                : doc.id;

            if (!groupedSales.containsKey(groupKey)) {
              groupedSales[groupKey] = [];
            }
            groupedSales[groupKey]!.add(sale);
          }
        } catch (e) {
          print('Error parsing sale document ${doc.id}: $e');
          continue;
        }
      }

      print('DEBUG: Grouped sales into ${groupedSales.length} groups');

      // Convert grouped sales to SalesGroup objects
      final List<SalesGroup> result = [];
      for (final salesGroup in groupedSales.values) {
        if (salesGroup.isNotEmpty) {
          try {
            result.add(SalesGroup.fromSales(salesGroup));
          } catch (e) {
            print('Error creating SalesGroup: $e');
            continue;
          }
        }
      }

      // Sort by date descending
      result.sort((a, b) => b.date.compareTo(a.date));

      print('DEBUG: Returning ${result.length} sales groups');
      return result;
    });
  }

  Future<void> cleanupInvalidSales(String farmerId) async {
    try {
      final salesSnapshot = await _db
          .collection('sales')
          .where('farmerId', isEqualTo: farmerId)
          .get();

      int deletedCount = 0;

      for (var doc in salesSnapshot.docs) {
        final data = doc.data();
        bool shouldDelete = false;

        // Check if this is a blank/invalid sale
        if (data['totalPrice'] == null || data['totalPrice'] == 0) {
          shouldDelete = true;
        }

        // Check if items array exists but is empty
        if (data.containsKey('items')) {
          final items = data['items'];
          if (items is List && items.isEmpty) {
            shouldDelete = true;
          }
        }

        // Check if it's missing essential fields
        if (data['customerId'] == null ||
            data['customerId'].toString().isEmpty) {
          shouldDelete = true;
        }

        if (shouldDelete) {
          print('Deleting invalid sale: ${doc.id}');
          await doc.reference.delete();
          deletedCount++;
        }
      }

      print('Cleaned up $deletedCount invalid sales for farmer: $farmerId');
    } catch (e) {
      print('Error cleaning up sales: $e');
    }
  }

  /// Debug method to check sales data structure for consolidated sales
  Future<void> debugConsolidatedSalesData(String farmerId) async {
    try {
      final salesSnapshot = await _db
          .collection('sales')
          .where('farmerId', isEqualTo: farmerId)
          .get();

      print('=== DEBUG: Consolidated Sales Data for Farmer: $farmerId ===');
      print('Total sales documents: ${salesSnapshot.docs.length}');

      int consolidatedCount = 0;
      int individualCount = 0;

      for (var doc in salesSnapshot.docs) {
        final data = doc.data();
        print('--- Sale Document ID: ${doc.id} ---');

        if (data.containsKey('items') && data['items'] is List) {
          consolidatedCount++;
          final items = data['items'] as List;
          print('TYPE: Consolidated Sale');
          print('OrderId: ${data['orderId']}');
          print('OrderSessionId: ${data['orderSessionId']}');
          print('Items count: ${items.length}');
          print('CustomerName: ${data['customerName']}');
          print('TotalPrice: ${data['totalPrice']}');
          print('Status: ${data['status']}');
          print('ImageUrl: ${data['imageUrl']}');
          if (items.isNotEmpty) {
            print('First item: ${items.first}');
          }
        } else {
          individualCount++;
          print('TYPE: Individual Sale');
          print('OrderSessionId: ${data['orderSessionId']}');
          print('ProductId: ${data['productId']}');
          print('Name: ${data['name']}');
          print('CustomerName: ${data['customerName']}');
        }
        print('Date: ${data['date'] ?? data['createdAt']}');
        print('---');
      }

      print(
        'Summary: $consolidatedCount consolidated, $individualCount individual sales',
      );
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error debugging consolidated sales data: $e');
    }
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
            (data['totalEarnings'] as num?)?.toInt() ?? 0;

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
          customerName: order.customerName,
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          totalPrice: item.price * item.quantity,
          date: Timestamp.now(),
          orderSessionId: order.orderSessionId,
          customerLocation: item.customerLocation,
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
    print('DEBUG: Farmer querying for orders with farmerId: $farmerId');
    return _db.collection('orders').snapshots().map((snapshot) {
      print('DEBUG: Total orders in database: ${snapshot.docs.length}');

      // Group orders by orderSessionId
      Map<String, List<Map<String, dynamic>>> ordersBySession = {};
      Set<String> farmerSessionIds = {};

      // First pass: identify which sessions contain this farmer's orders
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final orderFarmerId = data['farmerId'];
        final sessionId = data['orderSessionId']?.toString() ?? doc.id;

        if (orderFarmerId == farmerId) {
          farmerSessionIds.add(sessionId);
        }
      }

      // Second pass: collect all orders from sessions that include this farmer
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final sessionId = data['orderSessionId']?.toString() ?? doc.id;

        if (farmerSessionIds.contains(sessionId)) {
          if (!ordersBySession.containsKey(sessionId)) {
            ordersBySession[sessionId] = [];
          }
          ordersBySession[sessionId]!.add({'id': doc.id, ...data});
        }
      }

      // Convert grouped orders to combined orders
      List<model_orders.Orderlist> result = [];

      for (var entry in ordersBySession.entries) {
        final sessionId = entry.key;
        final ordersInSession = entry.value;

        if (ordersInSession.length == 1) {
          // Single order in session, add as is
          result.add(
            model_orders.Orderlist.fromMap(
              ordersInSession.first,
              ordersInSession.first['id'],
            ),
          );
        } else {
          // Multiple orders in session, combine them
          final firstOrder = ordersInSession.first;
          final combinedItems = <Map<String, dynamic>>[];
          int combinedTotalPrice = 0;

          for (var order in ordersInSession) {
            final items = order['items'] as List<dynamic>? ?? [];
            for (var item in items) {
              final itemMap = Map<String, dynamic>.from(item);
              // Mark items as belonging to this farmer or not
              itemMap['belongsToFarmer'] = order['farmerId'] == farmerId;
              combinedItems.add(itemMap);
            }
            combinedTotalPrice += (order['totalPrice'] as num?)?.toInt() ?? 0;
          }

          // Create combined order data
          final combinedOrderData = Map<String, dynamic>.from(firstOrder);
          combinedOrderData['items'] = combinedItems;
          combinedOrderData['totalPrice'] = combinedTotalPrice;
          combinedOrderData['farmerId'] =
              farmerId; // Keep farmer's ID for permissions
          combinedOrderData['isMultiFarmerOrder'] = ordersInSession.length > 1;

          result.add(
            model_orders.Orderlist.fromMap(combinedOrderData, sessionId),
          );
        }
      }

      print(
        'DEBUG: Found ${result.length} order sessions for farmer: $farmerId',
      );
      return result;
    });
  }

  Stream<List<model_orders.Orderlist>> getOrdersForCustomer(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
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
