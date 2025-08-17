import 'package:cloud_firestore/cloud_firestore.dart';

class Farmer {
  final String id;
  final String email;
  final String farmerName;
  final String radaRegistrationNumber;
  final String locationName;
  final GeoPoint location;
  final String? profileImageUrl;
  final String farmName;
  final bool isBanned;
  final bool isFlagged;

  Farmer({
    required this.id,
    required this.email,
    required this.farmerName,
    required this.radaRegistrationNumber,
    required this.locationName,
    required this.location,
    this.profileImageUrl,
    required this.farmName,
    this.isBanned = false,
    this.isFlagged = false,
  });
}
