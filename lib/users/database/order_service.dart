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

      // First, validate stock for all items before creating any orders
      for (var cartItem in cartSnapshot.docs) {
        final data = cartItem.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final productId = data['productId'];
        final quantity = data['customerQuantity'] ?? 1;

        if (productId != null) {
          // Check if stock is available (without deducting yet)
          final productDoc = await _db
              .collection('products')
              .doc(productId)
              .get();
          if (!productDoc.exists) {
            throw Exception('Product not found: ${data['name']}');
          }

          final productData = productDoc.data();
          final availableStock = (productData?['stock'] as num?)?.toInt() ?? 0;

          if (availableStock < quantity) {
            throw Exception(
              'Insufficient stock for ${data['name']}. Available: $availableStock, Requested: $quantity',
            );
          }
        }
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

      // Create separate order for each farmer with unique order IDs
      for (var entry in itemsByFarmer.entries) {
        final farmerId = entry.key;
        final farmerItems = entry.value;

        // Generate unique order ID for this farmer
        final farmerOrderId =
            '${DateTime.now().millisecondsSinceEpoch}_${farmerId}_$userId';

        await _createOrderForFarmer(
          userId,
          farmerId,
          farmerItems,
          farmerOrderId, // Each farmer gets their own unique order ID
        );

        print('Created order $farmerOrderId for farmer: $farmerId');
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

  Future<bool> calculateStock(String productId, int quantityToDeduct) async {
    try {
      final productDoc = await _db.collection('products').doc(productId).get();

      if (!productDoc.exists) {
        print("Product not found: $productId");
        return false;
      }

      final data = productDoc.data();
      if (data == null) {
        print("Product data is null for: $productId");
        return false;
      }

      final currentStock = (data['stock'] as num?)?.toInt() ?? 0;
      print(
        "Product ID: $productId, Current stock: $currentStock, Requested quantity: $quantityToDeduct",
      );

      if (currentStock < quantityToDeduct) {
        print(
          "Insufficient stock. Available: $currentStock, Requested: $quantityToDeduct",
        );
        return false;
      }

      final newStock = currentStock - quantityToDeduct;

      // Update the stock in the database
      await _db.collection('products').doc(productId).update({
        'stock': newStock,
        'lastStockUpdate': FieldValue.serverTimestamp(),
      });

      print(
        "Stock updated successfully. Product: $productId, New stock: $newStock",
      );
      return true;
    } catch (e) {
      print("Error calculating/updating stock for product $productId: $e");
      return false;
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
    String uniqueOrderId,
  ) async {
    int totalPrice = 0;
    List<Map<String, dynamic>> orderItems = [];

    // Convert cart items to order items and handle stock deduction
    for (var cartItem in cartItems) {
      final data = cartItem.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final quantity = data['customerQuantity'] ?? 1;
      final price = (data['price'] as num).toInt();
      final productId = data['productId'];

      // Calculate individual item total price
      final itemTotalPrice = (price * quantity).toInt();
      totalPrice += itemTotalPrice;

      // Handle stock deduction for this specific product
      if (productId != null) {
        try {
          final stockUpdated = await calculateStock(productId, quantity);
          if (!stockUpdated) {
            throw Exception('Insufficient stock for product: ${data['name']}');
          }
        } catch (e) {
          print('Failed to update stock for product $productId: $e');
          throw Exception('Failed to process order due to stock issues');
        }
      }

      orderItems.add({
        'productId': productId,
        'name': data['name'],
        'price': price, // Individual item price
        'quantity': quantity,
        'unit': data['unitType'] ?? 'piece',
        'imageUrl': data['imageUrl'] ?? '',
        'itemTotal': itemTotalPrice, // Total for this specific item
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
      'uniqueOrderId': uniqueOrderId, // Unique order ID for this farmer
    };

    // Add to main orders collection
    await _db.collection('orders').add(orderData);

    // Note: Sales records will be created only when farmer converts order to sale (adds receipt)

    // Update farmer's order statistics (but not sales statistics yet)
    await _updateFarmerStatistics(farmerId, totalPrice, orderItems.length);
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

  /// Get orders with sales data for customer (shows orders even when converted to sales)
  Stream<List<Map<String, dynamic>>> getOrdersWithSalesForCustomer(
    String customerId,
  ) {
    return Rx.combineLatest2(
      _db
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .snapshots(),
      _db
          .collection('sales')
          .where('customerId', isEqualTo: customerId)
          .snapshots(),
      (QuerySnapshot ordersSnapshot, QuerySnapshot salesSnapshot) {
        Map<String, Map<String, dynamic>> combinedOrders = {};

        // First, add all current orders
        for (var doc in ordersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final orderId = doc.id;

          combinedOrders[orderId] = {
            'id': orderId,
            'type': 'order',
            'hasReceipt': false,
            'receiptImageUrl': null,
            ...data,
          };
        }

        // Then, process sales records
        for (var doc in salesSnapshot.docs) {
          final salesData = doc.data() as Map<String, dynamic>;
          final orderId = salesData['orderId'] as String?;
          final receiptImageUrl = salesData['imageUrl'] as String?;

          if (orderId != null && combinedOrders.containsKey(orderId)) {
            // Case 1: Sales record corresponds to existing order - merge receipt data
            combinedOrders[orderId]!['hasReceipt'] =
                receiptImageUrl != null && receiptImageUrl.isNotEmpty;
            combinedOrders[orderId]!['receiptImageUrl'] = receiptImageUrl;
            combinedOrders[orderId]!['salesId'] = doc.id;
            combinedOrders[orderId]!['salesStatus'] = salesData['status'];

            // Use sales status as it's more up-to-date
            if (salesData['status'] != null) {
              combinedOrders[orderId]!['status'] = salesData['status'];
            }
          } else if (orderId != null) {
            // Case 2: Sales record has orderId but no matching order (order was deleted/moved)
            // Create a reconstructed order from sales data

            // Handle consolidated sales (with items array)
            if (salesData.containsKey('items') && salesData['items'] is List) {
              final items = salesData['items'] as List<dynamic>;

              combinedOrders[orderId] = {
                'id': orderId,
                'type': 'sale',
                'hasReceipt':
                    receiptImageUrl != null && receiptImageUrl.isNotEmpty,
                'receiptImageUrl': receiptImageUrl,
                'salesId': doc.id,
                'customerId': salesData['customerId'],
                'farmerId': salesData['farmerId'],
                'items': items,
                'totalPrice': salesData['totalPrice'],
                'status': salesData['status'] ?? 'completed',
                'createdAt': salesData['createdAt'] ?? salesData['date'],
                'uniqueOrderId': salesData['uniqueOrderId'],
                'customerName': salesData['customerName'],
                'customerLocation': salesData['customerLocation'],
              };
            } else {
              // Handle individual sales (old format)
              combinedOrders[orderId] = {
                'id': orderId,
                'type': 'sale',
                'hasReceipt':
                    receiptImageUrl != null && receiptImageUrl.isNotEmpty,
                'receiptImageUrl': receiptImageUrl,
                'salesId': doc.id,
                'customerId': salesData['customerId'],
                'farmerId': salesData['farmerId'],
                'items': [
                  {
                    'productId': salesData['productId'],
                    'name': salesData['name'],
                    'quantity': salesData['quantity'],
                    'price':
                        salesData['totalPrice'], // In old format, this is the total
                    'unit': salesData['unit'],
                    'imageUrl': salesData['imageUrl'],
                  },
                ],
                'totalPrice': salesData['totalPrice'],
                'status': salesData['status'] ?? 'completed',
                'createdAt': salesData['createdAt'] ?? salesData['date'],
                'customerName': salesData['customerName'],
                'customerLocation': salesData['customerLocation'],
              };
            }
          } else {
            // Case 3: Sales record without orderId (legacy data)
            // Use document ID as the key
            final fallbackOrderId = doc.id;

            if (salesData.containsKey('items') && salesData['items'] is List) {
              final items = salesData['items'] as List<dynamic>;

              combinedOrders[fallbackOrderId] = {
                'id': fallbackOrderId,
                'type': 'sale',
                'hasReceipt':
                    receiptImageUrl != null && receiptImageUrl.isNotEmpty,
                'receiptImageUrl': receiptImageUrl,
                'salesId': doc.id,
                'customerId': salesData['customerId'],
                'farmerId': salesData['farmerId'],
                'items': items,
                'totalPrice': salesData['totalPrice'],
                'status': salesData['status'] ?? 'completed',
                'createdAt': salesData['createdAt'] ?? salesData['date'],
                'uniqueOrderId': salesData['uniqueOrderId'],
                'customerName': salesData['customerName'],
                'customerLocation': salesData['customerLocation'],
              };
            } else {
              // Individual sale
              combinedOrders[fallbackOrderId] = {
                'id': fallbackOrderId,
                'type': 'sale',
                'hasReceipt':
                    receiptImageUrl != null && receiptImageUrl.isNotEmpty,
                'receiptImageUrl': receiptImageUrl,
                'salesId': doc.id,
                'customerId': salesData['customerId'],
                'farmerId': salesData['farmerId'],
                'items': [
                  {
                    'productId': salesData['productId'],
                    'name': salesData['name'],
                    'quantity': salesData['quantity'],
                    'price': salesData['totalPrice'],
                    'unit': salesData['unit'],
                    'imageUrl': salesData['imageUrl'],
                  },
                ],
                'totalPrice': salesData['totalPrice'],
                'status': salesData['status'] ?? 'completed',
                'createdAt': salesData['createdAt'] ?? salesData['date'],
                'customerName': salesData['customerName'],
                'customerLocation': salesData['customerLocation'],
              };
            }
          }
        }

        // Convert to list and sort by creation date
        final ordersList = combinedOrders.values.toList();
        ordersList.sort((a, b) {
          final aDate = a['createdAt'] as Timestamp?;
          final bDate = b['createdAt'] as Timestamp?;
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });

        return ordersList;
      },
    );
  }

  /// Get grouped orders for customer (by session to avoid duplicates)
  Stream<List<Map<String, dynamic>>> getGroupedOrdersForCustomer(
    String customerId,
  ) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // Group orders by orderSessionId
          Map<String, List<Map<String, dynamic>>> ordersBySession = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final sessionId = data['orderSessionId']?.toString() ?? doc.id;

            if (!ordersBySession.containsKey(sessionId)) {
              ordersBySession[sessionId] = [];
            }
            ordersBySession[sessionId]!.add({'id': doc.id, ...data});
          }

          // Create grouped orders
          List<Map<String, dynamic>> groupedOrders = [];

          for (var entry in ordersBySession.entries) {
            final sessionId = entry.key;
            final ordersInSession = entry.value;

            if (ordersInSession.length == 1) {
              // Single order, add as is
              groupedOrders.add(ordersInSession.first);
            } else {
              // Multiple orders from different farmers, combine them
              final firstOrder = ordersInSession.first;
              final allItems = <Map<String, dynamic>>[];
              int totalSessionPrice = 0;

              for (var order in ordersInSession) {
                final items = order['items'] as List<dynamic>? ?? [];
                allItems.addAll(
                  items.map((item) => Map<String, dynamic>.from(item)),
                );
                totalSessionPrice +=
                    (order['totalPrice'] as num?)?.toInt() ?? 0;

                // Add farmer info to each item for display
                final farmerId = order['farmerId'];
                for (var item in items) {
                  item['orderFarmerId'] = farmerId;
                }
              }

              // Create combined order
              final combinedOrder = Map<String, dynamic>.from(firstOrder);
              combinedOrder['id'] = sessionId;
              combinedOrder['items'] = allItems;
              combinedOrder['totalPrice'] = totalSessionPrice;
              combinedOrder['isMultiFarmerOrder'] = true;
              combinedOrder['farmerCount'] = ordersInSession.length;

              groupedOrders.add(combinedOrder);
            }
          }

          // Sort by creation date
          groupedOrders.sort((a, b) {
            final aDate = a['createdAt'] as Timestamp?;
            final bDate = b['createdAt'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });

          return groupedOrders;
        });
  }

  /// Get combined orders and sales data for a customer (shows complete order history)
  Stream<List<Map<String, dynamic>>> showOrdersForCustomer(String customerId) {
    return Rx.combineLatest2(
      FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('sales')
          .where('customerId', isEqualTo: customerId)
          .snapshots(),
      (QuerySnapshot ordersSnapshot, QuerySnapshot salesSnapshot) {
        List<Map<String, dynamic>> combinedData = [];

        // Add individual orders (don't group them for user display)
        for (var doc in ordersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            combinedData.add({...data, 'orderId': doc.id, 'type': 'order'});
          }
        }

        // Add sales data
        for (var doc in salesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            combinedData.add({...data, 'orderId': doc.id, 'type': 'sale'});
          }
        }

        // Sort by creation date (newest first)
        combinedData.sort((a, b) {
          final aDate = a['createdAt'] as Timestamp?;
          final bDate = b['createdAt'] as Timestamp?;
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });

        return combinedData;
      },
    );
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // Update the order status
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update corresponding sales record status
    await _updateSalesRecordStatus(orderId, newStatus);

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

  /// Update sales record status when order status changes
  Future<void> _updateSalesRecordStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      // Find and update sales record in main sales collection
      final salesQuery = await _db
          .collection('sales')
          .where('orderId', isEqualTo: orderId)
          .get();

      for (var saleDoc in salesQuery.docs) {
        await saleDoc.reference.update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Also update in farmer's personal sales subcollection
        final saleData = saleDoc.data();
        final farmerId = saleData['farmerId'];

        if (farmerId != null) {
          final farmerSalesQuery = await _db
              .collection('farmersData')
              .doc(farmerId)
              .collection('sales')
              .where('orderId', isEqualTo: orderId)
              .get();

          for (var farmerSaleDoc in farmerSalesQuery.docs) {
            await farmerSaleDoc.reference.update({
              'status': newStatus,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      print('Updated sales record status for order: $orderId to $newStatus');
    } catch (e) {
      print('Error updating sales record status: $e');
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

      // Restore stock for cancelled items
      await _restoreStockForCancelledOrder(orderData);

      // Update order and sales record status
      await updateOrderStatus(orderId, 'cancelled');
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  /// Restore stock when an order is cancelled
  Future<void> _restoreStockForCancelledOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final items = orderData['items'] as List<dynamic>? ?? [];

      for (var item in items) {
        final itemData = item as Map<String, dynamic>;
        final productId = itemData['productId'];
        final quantity = itemData['quantity'] ?? 0;

        if (productId != null && quantity > 0) {
          // Add the quantity back to stock
          final productRef = _db.collection('products').doc(productId);

          await _db.runTransaction((transaction) async {
            final productDoc = await transaction.get(productRef);

            if (productDoc.exists) {
              final productData = productDoc.data() ?? {};
              final currentStock = (productData['stock'] as num?)?.toInt() ?? 0;
              final newStock = currentStock + quantity;

              transaction.update(productRef, {
                'stock': newStock,
                'lastStockUpdate': FieldValue.serverTimestamp(),
              });

              print(
                'Restored stock for product $productId: +$quantity (new total: $newStock)',
              );
            }
          });
        }
      }
    } catch (e) {
      print('Error restoring stock for cancelled order: $e');
    }
  }

  /// Create consolidated sale record when farmer converts order to sale (adds receipt)
  Future<void> convertOrderToSale(
    String orderId,
    String receiptImageUrl,
  ) async {
    try {
      // Get the order data
      final orderDoc = await _db.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final orderData = orderDoc.data()!;
      final customerId = orderData['customerId'];
      final farmerId = orderData['farmerId'];
      final uniqueOrderId = orderData['uniqueOrderId'];
      final orderItems = orderData['items'] as List<dynamic>;
      final totalPrice = orderData['totalPrice'];

      // Get customer information
      final customerDoc = await _db.collection('users').doc(customerId).get();
      final customerData = customerDoc.data() ?? {};
      final customerName = customerData['name'] ?? 'Customer';
      final customerLocation = customerData['location'] ?? '';

      // Create consolidated sale data with all items from this customer order
      final saleData = {
        'customerId': customerId,
        'farmerId': farmerId,
        'orderId': orderId,
        'uniqueOrderId': uniqueOrderId,
        'items': orderItems,
        'totalPrice': totalPrice,
        'saleAmount': totalPrice, // Amount farmer will receive
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'date':
            FieldValue.serverTimestamp(), // For compatibility with existing sales model
        'type': 'customer_order',
        'orderSessionId':
            uniqueOrderId, // Use uniqueOrderId as session ID for grouping
        'customerName': customerName,
        'customerLocation': customerLocation,
        'imageUrl': receiptImageUrl, // Add the receipt image URL
      };

      // Create one consolidated sale record for all items from this customer
      await _db.collection('sales').add(saleData);

      // Also add to farmer's personal sales subcollection
      await _db
          .collection('farmersData')
          .doc(farmerId)
          .collection('sales')
          .add(saleData);

      // Update product statistics for each item
      for (var item in orderItems) {
        final productId = item['productId'];
        final quantity = item['quantity'] ?? 0;
        final price = item['price'] ?? 0;
        final itemTotalPrice = (price * quantity).toInt();

        if (productId != null) {
          final productDoc = await _db
              .collection('products')
              .doc(productId)
              .get();
          if (productDoc.exists) {
            final productData = productDoc.data()!;
            final currentTotalSold = (productData['totalSold'] as num? ?? 0)
                .toInt();
            final currentTotalEarnings =
                (productData['totalEarnings'] as num?)?.toInt() ?? 0;

            // Update product: increase total sold and earnings (stock was already deducted when order was created)
            await _db.collection('products').doc(productId).update({
              'totalSold': currentTotalSold + quantity,
              'totalEarnings': currentTotalEarnings + itemTotalPrice,
            });
          }
        }
      }

      print(
        'Consolidated sale record created for farmer: $farmerId, customer: $customerId, amount: \$$totalPrice',
      );
    } catch (e) {
      print('Error converting order to sale: $e');
      rethrow;
    }
  }

  /// Update farmer's statistics (total sales, order count, etc.)
  Future<void> _updateFarmerStatistics(
    String farmerId,
    int saleAmount,
    int itemCount,
  ) async {
    try {
      final farmerRef = _db.collection('farmersData').doc(farmerId);

      // Use a transaction to safely update statistics
      await _db.runTransaction((transaction) async {
        final farmerDoc = await transaction.get(farmerRef);

        if (farmerDoc.exists) {
          final data = farmerDoc.data() ?? {};

          // Update statistics
          final currentTotalSales = (data['totalSales'] as num?)?.toInt() ?? 0;
          final currentOrderCount = (data['orderCount'] as num?)?.toInt() ?? 0;
          final currentTotalItems =
              (data['totalItemsSold'] as num?)?.toInt() ?? 0;

          transaction.update(farmerRef, {
            'totalSales': currentTotalSales + saleAmount,
            'orderCount': currentOrderCount + 1,
            'totalItemsSold': currentTotalItems + itemCount,
            'lastOrderDate': FieldValue.serverTimestamp(),
            'lastSaleAmount': saleAmount,
          });
        } else {
          // If farmer document doesn't exist, create it with initial stats
          transaction.set(farmerRef, {
            'totalSales': saleAmount,
            'orderCount': 1,
            'totalItemsSold': itemCount,
            'lastOrderDate': FieldValue.serverTimestamp(),
            'lastSaleAmount': saleAmount,
          }, SetOptions(merge: true));
        }
      });

      print('Updated farmer statistics for: $farmerId');
    } catch (e) {
      print('Error updating farmer statistics for $farmerId: $e');
    }
  }

  /// Get sales data for a specific farmer
  Stream<List<Map<String, dynamic>>> getFarmerSales(String farmerId) {
    return _db
        .collection('sales')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Get farmer's sales statistics
  Future<Map<String, dynamic>> getFarmerStatistics(String farmerId) async {
    try {
      final farmerDoc = await _db.collection('farmersData').doc(farmerId).get();

      if (farmerDoc.exists) {
        final data = farmerDoc.data() ?? {};
        return {
          'totalSales': data['totalSales'] ?? 0,
          'orderCount': data['orderCount'] ?? 0,
          'totalItemsSold': data['totalItemsSold'] ?? 0,
          'lastOrderDate': data['lastOrderDate'],
          'lastSaleAmount': data['lastSaleAmount'] ?? 0,
        };
      }

      return {
        'totalSales': 0,
        'orderCount': 0,
        'totalItemsSold': 0,
        'lastOrderDate': null,
        'lastSaleAmount': 0,
      };
    } catch (e) {
      print('Error getting farmer statistics: $e');
      return {
        'totalSales': 0,
        'orderCount': 0,
        'totalItemsSold': 0,
        'lastOrderDate': null,
        'lastSaleAmount': 0,
      };
    }
  }
}
