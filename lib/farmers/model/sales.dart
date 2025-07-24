import 'package:cloud_firestore/cloud_firestore.dart';

class SalesGroup {
  final String sessionId;
  final String customerId;
  final String customerName;
  final String customerLocation;
  final List<Sale> items;
  final int totalPrice;
  final Timestamp date;

  SalesGroup({
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.customerLocation,
    required this.items,
    required this.totalPrice,
    required this.date,
  });

  factory SalesGroup.fromSales(List<Sale> sales) {
    if (sales.isEmpty) throw ArgumentError('Sales list cannot be empty');

    final firstSale = sales.first;
    final totalPrice = sales.fold(0, (sum, sale) => sum + sale.totalPrice);

    return SalesGroup(
      sessionId: firstSale.orderSessionId.isNotEmpty
          ? firstSale.orderSessionId
          : firstSale.salesId,
      customerId: firstSale.customerId,
      customerName: firstSale.customerName,
      customerLocation: firstSale.customerLocation,
      items: sales,
      totalPrice: totalPrice,
      date: firstSale.date,
    );
  }
}

class Sale {
  final String salesId;
  final String productId;
  final String name;
  final int quantity;
  final int totalPrice;
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
    this.orderSessionId = '',
    this.customerLocation = '',
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
    totalPrice: (map['totalPrice'] as num?)?.toInt() ?? 0,
    date: map['date'] as Timestamp? ?? Timestamp.now(),
    customerId: map['customerId']?.toString() ?? '',
    customerName: map['customerName']?.toString() ?? 'Unknown Customer',
    farmerId: map['farmerId']?.toString() ?? '',
    unit: map['unit']?.toString() ?? '',
    orderSessionId: map['orderSessionId']?.toString() ?? '',
    customerLocation: map['customerLocation']?.toString() ?? '',
  );
}
