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
  final String minUnitNum;
  final String imageUrl;
  final DateTime createdAt;
  final int totalSold;
  final double totalEarnings;
  final String customerLocation;
  final bool isComplete;
  final bool isActive;
  final bool isTool; // New field to distinguish farming tools/equipment

  Product({
    required this.productId,
    required this.farmerId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.unit,
    required this.stock,
    required this.minUnitNum,
    required this.imageUrl,
    required this.createdAt,
    this.totalSold = 0,
    this.totalEarnings = 0.0,
    this.customerLocation = 'change in model',
    this.isComplete = true,
    this.isActive = true,
    this.isTool = false, // Default to false for regular products
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
      'minUnitNum': minUnitNum,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'totalSold': totalSold,
      'totalEarnings': totalEarnings,
      'isComplete': isComplete,
      'isActive': isActive,
      'isTool': isTool,
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
    String? minUnitNum,
    DateTime? createdAt,
    String? customerLocation,
    String? productId,
    String? imageUrl,
    int? stock,
    int? totalSold,
    double? totalEarnings,
    bool? isTool,
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
      minUnitNum: minUnitNum ?? this.minUnitNum,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      totalSold: totalSold ?? this.totalSold,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      isTool: isTool ?? this.isTool,
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
      minUnitNum: map['minUnitNum']?.toString() ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalSold: map['totalSold'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0).toDouble(),
      customerLocation: map['customerLocation'] ?? 'change in model',
      isComplete: map['isComplete'] ?? true,
      isActive: map['isActive'] ?? true,
      isTool: map['isTool'] ?? false,
    );
  }
}
