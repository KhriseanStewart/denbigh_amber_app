import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:denbigh_app/farmers/model/products.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsForFarmer(String farmerId) {
    return _db
        .collection('products')
        .where(
          'farmerId',
          isEqualTo: farmerId,
        ) // Farmers see ALL their products (complete and incomplete)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Product.fromMap({
                  ...doc.data(),
                  'productId': doc.id,
                }, doc.id),
              )
              .toList(),
        );
  }

  // Method to get only complete products for farmers (for public displays)
  Stream<List<Product>> getCompleteProductsForFarmer(String farmerId) {
    return _db
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .where('isComplete', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Product.fromMap({
                  ...doc.data(),
                  'productId': doc.id,
                }, doc.id),
              )
              .toList(),
        );
  }

  Future<DocumentReference> addProduct(Product product) async {
    final docRef = await FirebaseFirestore.instance
        .collection('products')
        .add(product.toMap());
    await docRef.update({'productId': docRef.id});
    return docRef;
  }

  Future<void> updateProduct(Product product) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.productId)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  Future<Product> createProduct(Product product) async {
    final data = product.toMap();
    data.remove('productId');

    final docRef = await FirebaseFirestore.instance
        .collection('products')
        .add(data);

    await docRef.update({'productId': docRef.id});

    return product.copyWith(productId: docRef.id);
  }

  // Update single item cart status
  Future<void> updateSingleItemCartStatus(
    String productId,
    bool isInCart,
  ) async {
    await _db.collection('products').doc(productId).update({
      'isInCart': isInCart,
    });
  }

  // Mark single item as in cart
  Future<void> markSingleItemInCart(String productId) async {
    await updateSingleItemCartStatus(productId, true);
  }

  // Mark single item as not in cart
  Future<void> markSingleItemNotInCart(String productId) async {
    await updateSingleItemCartStatus(productId, false);
  }
}
