import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String salesId;
  final String productId;
  final String name;
  final int quantity;
  final double totalPrice;
  final Timestamp date;
  final String customerId;
  final String farmerId;
  final String unit;

  Sale({
    required this.salesId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.totalPrice,
    required this.date,
    required this.customerId,
    required this.farmerId,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
    'salesId': salesId,
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'totalPrice': totalPrice,
    'date': date,
    'customerId': customerId,
    'farmerId': farmerId,
    'unit': unit,
  };

  factory Sale.fromMap(Map<String, dynamic> map, String salesId) => Sale(
    salesId: map['salesId'] ?? salesId,
    productId: map['productId'] ?? '',
    name: map['name'] ?? '',
    quantity: map['quantity'] ?? 0,
    totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    date: map['date'] as Timestamp,
    customerId: map['customerId'] ?? '',
    farmerId: map['farmerId'] ?? '',
    unit: map['unit'] ?? '',
  );
}
