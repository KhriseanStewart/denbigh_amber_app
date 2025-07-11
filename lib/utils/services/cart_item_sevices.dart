

// 
// 
// not yet implemented





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cartCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User is not authenticated');
    return _db.collection('users').doc(user.uid).collection('cart');
  }

  /// Adds a new item to cart or increments quantity if exists
  Future<void> addItem(Map<String, dynamic> product) async {
    final cartRef = _cartCollection();

    final query = await cartRef.where('name', isEqualTo: product['name']).limit(1).get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final currentQty = doc.data()['quantity'] ?? 1;
      await doc.reference.update({
        'quantity': currentQty + (product['quantity'] ?? 1),
      });
    } else {
      await cartRef.add({
        'name': product['name'],
        'image': product['image'],
        'price': product['price'],
        'quantity': product['quantity'] ?? 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Increases quantity of a given cart item (identified by document id)
  Future<void> increaseQty(String docId) async {
    final docRef = _cartCollection().doc(docId);
    await docRef.update({
      'quantity': FieldValue.increment(1),
    });
  }

  /// Decreases quantity of a cart item, deletes it if quantity reaches zero
  Future<void> decreaseQty(String docId, int currentQty) async {
    final docRef = _cartCollection().doc(docId);
    if (currentQty > 1) {
      await docRef.update({
        'quantity': FieldValue.increment(-1),
      });
    } else {
      await docRef.delete();
    }
  }

  /// Deletes a cart item by document id
  Future<void> deleteItem(String docId) async {
    await _cartCollection().doc(docId).delete();
  }

  /// Clears all items in the user’s cart
  Future<void> clearCart() async {
    final cartRef = _cartCollection();
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Returns a stream of cart items for realtime UI updates
  Stream<QuerySnapshot<Map<String, dynamic>>> getCartStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _cartCollection().orderBy('timestamp').snapshots();
  }
}