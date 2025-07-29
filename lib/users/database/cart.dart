import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cart_Service {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> addToCart(
    String userId,
    QueryDocumentSnapshot productData,
    int quantity,
  ) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cartItems');

    //checks if product id already exists and updates it if it does
    final productId = productData['productId'];
    final existingItem = await cartRef
        .where('productId', isEqualTo: productId)
        .get();

    if (existingItem.docs.isNotEmpty) {
      final docId = existingItem.docs.first.id;
      await cartRef.doc(docId).update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      //add the item
      await cartRef.add({
        'productId': productData['productId'],
        'name': productData['name'],
        'description': productData['description'],
        'price': productData['price'],
        'imageUrl': productData['imageUrl'],
        'customerQuantity': quantity,
        'currency': 'J',
        'category': productData['category'],
        'minUnitNum': productData['minUnitNum'],
        'unitType': productData['unit'],
        'quantity': productData['stock'],
        'location': productData['location'],
        'farmerId': productData['farmerId'], // Add farmerId for order grouping
      });
    }
  }

  Future<void> updateCartItemQuantity(
    String userId,
    String productId,
    int newQuantity,
  ) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cartItems');

    // Find the document with the matching productId
    final querySnapshot = await cartRef
        .where('productId', isEqualTo: productId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;

      // Update the quantity
      await cartRef.doc(docId).update({'customerQuantity': newQuantity});
    } else {
      // Handle the case where the item isn't found, if necessary
      print('Item with productId $productId not found in cart.');
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cartItems');

    final docSnapshot = await cartRef
        .where('productId', isEqualTo: productId)
        .get();

    if (docSnapshot.docs.isNotEmpty) {
      await cartRef.doc(docSnapshot.docs.first.id).delete();
    }
  }
  Future<bool> isProductInCart(String userId, String productId) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cartItems');

    final querySnapshot = await cartRef
        .where('productId', isEqualTo: productId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
  Stream<QuerySnapshot> readCart(String uid) {
    return _db.collection("users").doc(uid).collection("cartItems").snapshots();
  }
}
