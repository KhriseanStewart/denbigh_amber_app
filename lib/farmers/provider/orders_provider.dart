// import 'package:denbigh_app/farmers/model/orders.dart';
// import 'package:flutter/material.dart';

// class OrdersProvider extends ChangeNotifier {
//   Orderlist? _currentOrder;

//   Orderlist? get currentOrder => _currentOrder;

//   set currentOrder(Orderlist? order) {
//     _currentOrder = order;
//     notifyListeners();
//   }

//   /// Computes the total quantity of all items in the current order
//   int get totalQuantity {
//     if (_currentOrder == null) return 0;
//     return _currentOrder!.items.fold(0, (sum, item) => sum + item.quantity);
//   }

//   /// Add an item to the current order (or increase its quantity)
//   void addItem(OrderItem item) {
//     if (_currentOrder == null) {
//       // If no order, create one with this item
//       _currentOrder = Orderlist(
//         customerLocation: item.customerLocation,
//         unit: item.unit,
//         name: item.name,
//         orderId: '',
//         quantity: item.quantity.toString(),
//         customerId: '',
//         customerName: 'Unknown Customer',
//         farmerId: item.farmerId,
//         items: [item],
//         totalPrice: item.price * item.quantity,
//         status: 'processing',
//         createdAt: DateTime.now(),
//         imageUrl: item.imageUrl,
//       );
//       notifyListeners();
//       return;
//     }

//     // Check if item already exists in the order
//     int index = _currentOrder!.items.indexWhere(
//       (i) => i.productId == item.productId,
//     );
//     if (index != -1) {
//       // Increase quantity
//       _currentOrder!.items[index] = OrderItem(
//         orderId: _currentOrder!.orderId,
//         customerLocation: item.customerLocation,
//         productId: item.productId,
//         name: item.name,
//         unit: item.unit,
//         quantity: _currentOrder!.items[index].quantity + item.quantity,
//         price: item.price,
//         imageUrl: item.imageUrl,
//         farmerId: item.farmerId,
//       );
//     } else {
//       // Add new item
//       _currentOrder!.items.add(item);
//     }
//     notifyListeners();
//   }

//   /// Remove an item from the current order entirely
//   void removeItem(String productId) {
//     if (_currentOrder == null) return;
//     _currentOrder!.items.removeWhere((i) => i.productId == productId);
//     notifyListeners();
//   }

//   /// Increase quantity of an item in the current order
//   void increaseQty(String productId) {
//     if (_currentOrder == null) return;
//     int index = _currentOrder!.items.indexWhere(
//       (i) => i.productId == productId,
//     );
//     if (index != -1) {
//       var item = _currentOrder!.items[index];
//       _currentOrder!.items[index] = OrderItem(
//         orderId: _currentOrder!.orderId,
//         customerLocation: item.customerLocation,
//         productId: item.productId,
//         name: item.name,
//         quantity: item.quantity + 1,
//         price: item.price,
//         imageUrl: item.imageUrl,
//         farmerId: item.farmerId,
//         unit: item.unit,
//       );
//       notifyListeners();
//     }
//   }

//   /// Decrease quantity of an item in the current order, remove if zero
//   void decreaseQty(String productId) {
//     if (_currentOrder == null) return;
//     int index = _currentOrder!.items.indexWhere(
//       (i) => i.productId == productId,
//     );
//     if (index != -1) {
//       var item = _currentOrder!.items[index];
//       if (item.quantity > 1) {
//         _currentOrder!.items[index] = OrderItem(
//           orderId: _currentOrder!.orderId,
//           customerLocation: item.customerLocation,
//           productId: item.productId,
//           unit: item.unit,
//           name: item.name,
//           quantity: item.quantity - 1,
//           price: item.price,
//           imageUrl: item.imageUrl,
//           farmerId: item.farmerId,
//         );
//       } else {
//         _currentOrder!.items.removeAt(index);
//       }
//       notifyListeners();
//     }
//   }

//   /// Clear the current order (e.g., on checkout)
//   void clearOrder() {
//     _currentOrder = null;
//     notifyListeners();
//   }
// }
