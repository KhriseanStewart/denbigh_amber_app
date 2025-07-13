import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> getProducts() {
    return _db.collection("products").snapshots();
  }
}
