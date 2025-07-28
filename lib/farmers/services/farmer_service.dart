import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerService {
  // Use 'farmersData' for all farmer-specific information
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'farmersData',
  );

  Future<void> createfarmersData({
    required String farmerId,
    required String farmName,
    required String farmerName,
    required String radaRegistrationNumber,
    required GeoPoint location,
    required String locationName,
    String? profileImageUrl,
    required String email,
  }) {
    return _col.doc(farmerId).set({
      'email': email,
      'farmerId': farmerId,
      'farmName': farmName,
      'farmerName': farmerName,
      'radaRegistrationNumber': radaRegistrationNumber,
      'location': location,
      'locationName': locationName,
      'createdAt': FieldValue.serverTimestamp(),
      'profileImageUrl': profileImageUrl,
    });
  }

  Future<DocumentSnapshot> getfarmersData(String farmerId) {
    return _col.doc(farmerId).get();
  }

  Future<void> updatefarmersData({
    required String farmerId,
    String? farmerName,
    String? locationName,
    GeoPoint? location,
    String? profileImageUrl,
    String? email,
    required String? farmName,
  }) {
    Map<String, dynamic> updateData = {};

    if (farmerName != null) updateData['farmerName'] = farmerName;
    if (farmName != null) updateData['farmName'] = farmName;
    if (locationName != null) updateData['locationName'] = locationName;
    if (location != null) updateData['location'] = location;
    if (profileImageUrl != null) {
      updateData['profileImageUrl'] = profileImageUrl;
    }
    if (email != null) updateData['email'] = email;

    updateData['updatedAt'] = FieldValue.serverTimestamp();

    return _col.doc(farmerId).update(updateData);
  }

  // Keep the old method names for backward compatibility
  Future<void> createFarmerData({
    required String farmerId,
    final String? farmName,
    required String farmerName,
    required String radaRegistrationNumber,
    required GeoPoint location,
    required String locationName,
    String? profileImageUrl,
    required String email,
  }) => createfarmersData(
    email: email,
    farmName: farmName ?? 'Unknown Farm',
    farmerId: farmerId,
    farmerName: farmerName,
    radaRegistrationNumber: radaRegistrationNumber,
    location: location,
    locationName: locationName,
    profileImageUrl: profileImageUrl,
  );

  Future<DocumentSnapshot> getFarmerData(String farmerId) =>
      getfarmersData(farmerId);

  Future<void> updateFarmerData({
    required String farmName,
    required String email,
    required String farmerId,
    String? farmerName,
    String? locationName,
    GeoPoint? location,
    String? profileImageUrl,
  }) => updatefarmersData(
    farmName: farmName,
    email: email,
    farmerId: farmerId,
    farmerName: farmerName,
    locationName: locationName,
    location: location,
    profileImageUrl: profileImageUrl,
  );
}
