import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerService {
  // Use 'farmersData' to match the collection used by customer service and farmer auth
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'farmersData',
  );

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
