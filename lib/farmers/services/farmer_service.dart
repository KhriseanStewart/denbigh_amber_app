import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerService {
  // Consistently use 'farmerData' for all farmer-specific information
  final CollectionReference _col = FirebaseFirestore.instance.collection('farmerData');

  Future<void> createFarmerData({
    required String farmerId,
    required String farmerName,
    required String radaRegistrationNumber,
    required GeoPoint location,
    required String locationName,
  }) {
    return _col.doc(farmerId).set({
      'farmerId': farmerId,
      'farmerName': farmerName,
      'radaRegistrationNumber': radaRegistrationNumber,
      'location': location,
      'locationName': locationName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getFarmerData(String farmerId) {
    return _col.doc(farmerId).get();
  }
}