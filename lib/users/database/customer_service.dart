// lib/services/customer_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerService {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'customersData',
  );

  /// Creates (or overwrites) the customer’s data doc with the fields:
  /// userId, firstName, lastName, address, currentLocation, joinedAt
  Future<void> createCustomerData({
    required String uid,
    required String firstName,
    required String lastName,
    required String? address,
    required GeoPoint? currentLocation,
  }) {
    return _col.doc(uid).set({
      'userId': uid,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'currentLocation': currentLocation,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches the customer’s data
  Future<DocumentSnapshot> getCustomerData(String uid) {
    return _col.doc(uid).get();
  }
}
