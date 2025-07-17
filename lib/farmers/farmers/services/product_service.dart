import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/farmers/model/products.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsForFarmer(String farmerId) {
    return _db
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
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
}
