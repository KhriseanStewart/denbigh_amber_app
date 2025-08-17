import 'package:cloud_firestore/cloud_firestore.dart';

class SalesGroup {
  final String sessionId;
  final String customerId;
  final String customerName;
  final String farmerId;
  final List<Sale> items;
  final double totalPrice;
  final Timestamp date;
  final String customerLocation;

  SalesGroup({
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.farmerId,
    required this.items,
    required this.totalPrice,
    required this.date,
    required this.customerLocation,
  });

  factory SalesGroup.fromSales(List<Sale> sales) {
    if (sales.isEmpty) {
      throw Exception('Cannot create SalesGroup from empty sales list');
    }

    final firstSale = sales.first;
    return SalesGroup(
      sessionId: firstSale.orderSessionId.isNotEmpty
          ? firstSale.orderSessionId
          : firstSale.salesId,
      customerId: firstSale.customerId,
      customerName: firstSale.customerName,
      farmerId: firstSale.farmerId,
      items: sales,
      totalPrice: sales.fold(0.0, (sum, sale) => sum + sale.totalPrice),
      date: firstSale.date,
      customerLocation: firstSale.customerLocation,
    );
  }

  Map<String, dynamic> toMap() => {
    'sessionId': sessionId,
    'customerId': customerId,
    'customerName': customerName,
    'farmerId': farmerId,
    'items': items.map((e) => e.toMap()).toList(),
    'totalPrice': totalPrice,
    'date': date,
    'customerLocation': customerLocation,
  };

  factory SalesGroup.fromMap(Map<String, dynamic> map, String sessionId) =>
      SalesGroup(
        sessionId: sessionId,
        customerId: map['customerId'] ?? '',
        customerName: map['customerName'] ?? 'Unknown Customer',
        farmerId: map['farmerId'] ?? '',
        items: (map['items'] as List<dynamic>? ?? [])
            .map((e) => Sale.fromMap(e as Map<String, dynamic>, ''))
            .toList(),
        totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
        date: map['date'] as Timestamp? ?? Timestamp.now(),
        customerLocation: map['customerLocation'] ?? '',
      );
}

class Sale {
  final String salesId;
  final String productId;
  final String name;
  final int quantity;
  final double totalPrice;
  final Timestamp date;
  final String customerId;
  final String customerName;
  final String farmerId;
  final String unit;
  final String orderSessionId;
  final String customerLocation;

  Sale({
    required this.salesId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.totalPrice,
    required this.date,
    required this.customerId,
    required this.customerName,
    required this.farmerId,
    required this.unit,
    required this.orderSessionId,
    required this.customerLocation,
  });

  Map<String, dynamic> toMap() => {
    'salesId': salesId,
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'totalPrice': totalPrice,
    'date': date,
    'customerId': customerId,
    'customerName': customerName,
    'farmerId': farmerId,
    'unit': unit,
    'orderSessionId': orderSessionId,
    'customerLocation': customerLocation,
  };

  factory Sale.fromMap(Map<String, dynamic> map, String salesId) => Sale(
    salesId: map['salesId']?.toString() ?? salesId,
    productId: map['productId']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    date: map['date'] as Timestamp? ?? Timestamp.now(),
    customerId: map['customerId']?.toString() ?? '',
    customerName: map['customerName']?.toString() ?? 'Unknown Customer',
    farmerId: map['farmerId']?.toString() ?? '',
    unit: map['unit']?.toString() ?? '',
    orderSessionId: map['orderSessionId']?.toString() ?? '',
    customerLocation: map['customerLocation']?.toString() ?? '',
  );
}
