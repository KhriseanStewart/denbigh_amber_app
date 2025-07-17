import 'package:cloud_firestore/cloud_firestore.dart';

class Farmer {
  final String id;
  final String email;
  final String farmerName;
  final String radaRegistrationNumber;
  final String locationName;
  final GeoPoint location;
  

  Farmer({
    required this.id,
    required this.email,
    required this.farmerName,
    required this.radaRegistrationNumber,
    required this.locationName,
    required this.location,
  });
}