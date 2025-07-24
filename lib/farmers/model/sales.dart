import 'package:cloud_firestore/cloud_firestore.dart';

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
  );
}
