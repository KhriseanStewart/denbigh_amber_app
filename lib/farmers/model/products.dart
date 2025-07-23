import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productId;
  final String farmerId;
  final String name;
  final String description;
  final List<String> category;
  final double price;
  final List<String> unit;
  final int stock;
  final String minSaleAmount;
  final String imageUrl;
  final DateTime createdAt;
  final int totalSold;
final double totalEarnings;
final String customerLocation;

  Product({
    required this.productId,
    required this.farmerId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.unit,
    required this.stock,
    required this.minSaleAmount,
    required this.imageUrl,
    required this.createdAt,
    this.totalSold = 0,
    this.totalEarnings = 0.0,
    this.customerLocation = 'change in model',
  });

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'customerLocation': customerLocation,
      'productId': productId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'unit': unit,
      'stock': stock,
      'minUnitNum': minSaleAmount,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'totalSold': totalSold,
      'totalEarnings': totalEarnings,
    };
  }

  //THIS IS THE CORRECT VERSION 
  Product copyWith({
    String? farmerId,
    String? name, 
    String? description,
    List<String>? category,
    double? price,
    List<String>? unit,
    String? minSaleAmount,
    DateTime? createdAt,
    String? customerLocation,

    String? productId,
    String? imageUrl,
    int? stock, 
    int? totalSold,
  double? totalEarnings,
  }) {
    return Product(
      productId: productId ?? this.productId,
      customerLocation: customerLocation ?? this.customerLocation,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minSaleAmount: minSaleAmount ?? this.minSaleAmount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      totalSold: totalSold ?? this.totalSold,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      
    );
  }
  // --------------------------------------

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      productId: map['productId'] ?? id,
      farmerId: map['farmerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] is List
          ? List<String>.from(map['category'])
          : (map['category'] is String && map['category'].isNotEmpty)
              ? [map['category']]
              : [],
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] is List
          ? List<String>.from(map['unit'])
          : (map['unit'] is String && map['unit'].isNotEmpty)
              ? [map['unit']]
              : [],
      stock: map['stock'] ?? 0,
      minSaleAmount: map['minSaleAmount'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalSold: map['totalSold'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0).toDouble(),
      customerLocation: map['customerLocation'] ?? 'change in model',
    );
  }
}


