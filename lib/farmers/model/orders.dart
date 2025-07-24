import 'package:cloud_firestore/cloud_firestore.dart';

// this is for an entire order, not just a sale
class Orderlist {
  final String orderId;
  final String name;
  final String unit;
  final String quantity;
  final String customerId;
  final String customerName;
  final String farmerId;
  final List<OrderItem> items;
  final int totalPrice;
  final String status;
  final DateTime createdAt;
  final String? imageUrl;
  final String customerLocation;

  Orderlist({
    required this.orderId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.customerId,
    required this.customerName,
    required this.farmerId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.imageUrl,
    required this.customerLocation,
  });

  // Factory constructor to create an Order from a Firestore map
  factory Orderlist.fromMap(Map<String, dynamic> map, String docId) {
    // Safely handle items first
    final itemsList = (map['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
        .toList();

    // Get the first item for backwards compatibility, or use defaults
    final firstItem = itemsList.isNotEmpty ? itemsList.first : null;

    return Orderlist(
      unit: firstItem?.unit ?? map['unit']?.toString() ?? '',
      name: firstItem?.name ?? map['name']?.toString() ?? '',
      orderId: docId,
      imageUrl: map['imageUrl']?.toString(),
      quantity:
          firstItem?.quantity.toString() ?? map['quantity']?.toString() ?? '0',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? 'Unknown Customer',
      farmerId: map['farmerId']?.toString() ?? '',
      items: itemsList,
      totalPrice: (map['totalPrice'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'processing',
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      customerLocation: map['customerLocation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'name': name,
      'customerId': customerId,
      'customerName': customerName,
      'farmerId': farmerId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'unit': unit,
      'customerLocation': customerLocation,
    };
  }
}

// while this represents an item in the order
class OrderItem {
  final String productId;
  final String unit;
  final String name;
  final int quantity;
  final int price;
  final String? imageUrl;
  final String farmerId;
  final String customerLocation;
  final String orderId;

  OrderItem({
    required this.orderId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    required this.unit,
    required this.farmerId,
    required this.customerLocation,
  });

  // Factory constructor to create an OrderItem from a map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    int parsedQuantity = 0;
    var q = map['quantity'];
    if (q is int) {
      parsedQuantity = q;
    } else if (q is String) {
      parsedQuantity = int.tryParse(q) ?? 0;
    } else if (q is num) {
      parsedQuantity = q.round();
    }

    int parsedPrice = 0;
    var p = map['price'];
    if (p is double) {
      parsedPrice = p.toInt();
    } else if (p is int) {
      parsedPrice = p;
    } else if (p is String) {
      parsedPrice = int.tryParse(p) ?? 0;
    } else if (p is num) {
      parsedPrice = p.toInt();
    }

    return OrderItem(
      productId: map['productId']?.toString() ?? '',
      unit: map['unit']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      farmerId: map['farmerId']?.toString() ?? '',
      quantity: parsedQuantity,
      price: parsedPrice,
      imageUrl: map['imageUrl']?.toString(),
      customerLocation: map['customerLocation']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'unit': unit,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'farmerId': farmerId,
      'customerLocation': customerLocation,
    };
  }
}
