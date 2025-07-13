// lib/services/farmer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing the “farmersData” collection.
/// Each farmer doc has:
///  • userId         — the farmer’s Auth UID
///  • farmName       — the name of the farm
///  • farmersAddress — street or mailing address
///  • location       — GeoPoint representing lat/lng
///  • locationName   — human-readable place name
///  • createdAt      — Firestore server timestamp
class FarmerService {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'farmersData',
  );

  /// Create or overwrite the farmer’s data doc.
  /// Call this right after signup (when role == 'farmer').
  Future<void> createFarmerData({
    required String uid,
    required String farmName,
    required String farmersAddress,
    required GeoPoint location,
    required String locationName,
    required String radaRegistrationNumber,
  }) {
    return _col.doc(uid).set({
      'userId': uid,
      'farmName': farmName,
      'farmersAddress': farmersAddress,
      'location': location,
      'locationName': locationName,
      'createdAt': FieldValue.serverTimestamp(),
      'radaRegistrationNumber': radaRegistrationNumber,
    });
  }

  /// Fetch the farmer’s data document.
  Future<DocumentSnapshot> getFarmerData(String uid) {
    return _col.doc(uid).get();
  }

  /// Update only the fields you pass in.
  /// E.g. to correct the address or move the location.
  Future<void> updateFarmerData({
    required String uid,
    String? farmName,
    String? farmersAddress,
    GeoPoint? location,
    String? locationName,
    String? radaRegistrationNumber,
  }) {
    final updates = <String, dynamic>{};
    if (farmName != null) updates['farmName'] = farmName;
    if (farmersAddress != null) updates['farmersAddress'] = farmersAddress;
    if (location != null) updates['location'] = location;
    if (locationName != null) updates['locationName'] = locationName;
    if (radaRegistrationNumber != null) {
      updates['radaRegistrationNumber'] = radaRegistrationNumber;
    }
    return _col.doc(uid).update(updates);
  }
}
