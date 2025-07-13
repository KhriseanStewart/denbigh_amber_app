// lib/services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'products',
  );

  /// Create or overwrite a product.
  /// If you pass `productId`, it’ll use that; otherwise Firestore will auto-ID.
  Future<void> createProduct({
    String? productId,
    required String name,
    required String category,
    String? description,
    required num price,
    required String currency,
    required num quantity,
    required String unitType,
    required String location,
    required String sellerId,
    List<String>? imageUrls,
  }) {
    final data = {
      'name': name,
      'category': category,
      'description': description ?? '',
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'unitType': unitType,
      'location': location,
      'sellerId': sellerId,
      'imageUrls': imageUrls ?? [],
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (productId != null) {
      return _col.doc(productId).set(data);
    } else {
      return _col.add(data);
    }
  }

  /// Read a single product
  Future<DocumentSnapshot> getProduct(String productId) {
    return _col.doc(productId).get();
  }

  /// Update only the fields you pass in
  Future<void> updateProduct({
    required String productId,
    String? name,
    String? category,
    String? description,
    num? price,
    String? currency,
    num? quantity,
    String? unitType,
    String? location,
    List<String>? imageUrls,
    bool? isActive,
  }) {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) updates['name'] = name;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (price != null) updates['price'] = price;
    if (currency != null) updates['currency'] = currency;
    if (quantity != null) updates['quantity'] = quantity;
    if (unitType != null) updates['unitType'] = unitType;
    if (location != null) updates['location'] = location;
    if (imageUrls != null) updates['imageUrls'] = imageUrls;
    if (isActive != null) updates['isActive'] = isActive;

    return _col.doc(productId).update(updates);
  }

  /// “Soft” delete or hide a product
  Future<void> deleteProduct(String productId) {
    return _col.doc(productId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// List all products for a given seller (farmer)
  Stream<QuerySnapshot> streamProductsBySeller(String sellerId) {
    return _col
        .where('sellerId', isEqualTo: sellerId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Optionally: list all products in a category
  Stream<QuerySnapshot> streamProductsByCategory(String category) {
    return _col
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }
}
