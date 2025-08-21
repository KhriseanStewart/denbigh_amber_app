import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:denbigh_app/farmers/services/product_service.dart';

class Cart_Service {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
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
        'customerQuantity': FieldValue.increment(quantity),
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

      // If this is a single item, mark it as in cart
      final isSingleItem = productData['isSingleItem'] ?? false;
      if (isSingleItem) {
        await _productService.markSingleItemInCart(productData['productId']);
      }
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

      // If this was a single item, mark it as not in cart
      // We need to check the product data to see if it's a single item
      try {
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final productData = productDoc.data() as Map<String, dynamic>;
          final isSingleItem = productData['isSingleItem'] ?? false;
          if (isSingleItem) {
            await _productService.markSingleItemNotInCart(productId);
          }
        }
      } catch (e) {
        print('Error updating single item cart status: $e');
      }
    }
  }

  // Remove cart item by document ID directly
  Future<void> removeCartItem(String userId, String cartItemId) async {
    try {
      // First get the cart item data to check if it's a single item
      final cartItemDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .doc(cartItemId)
          .get();

      if (cartItemDoc.exists) {
        final cartItemData = cartItemDoc.data() as Map<String, dynamic>;
        final productId = cartItemData['productId'];

        // Delete the cart item
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cartItems')
            .doc(cartItemId)
            .delete();

        // Check if it was a single item and update its status
        if (productId != null) {
          try {
            final productDoc = await FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .get();

            if (productDoc.exists) {
              final productData = productDoc.data() as Map<String, dynamic>;
              final isSingleItem = productData['isSingleItem'] ?? false;
              if (isSingleItem) {
                await _productService.markSingleItemNotInCart(productId);
              }
            }
          } catch (e) {
            print('Error updating single item cart status: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to remove cart item: $e');
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
