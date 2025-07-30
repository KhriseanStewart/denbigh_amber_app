import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:denbigh_app/farmers/model/farmers.dart';
import 'package:denbigh_app/farmers/services/farmer_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Farmer? _farmer;

  bool get isAuthenticated => _farmer != null;
  Farmer? get farmer => _farmer;

  // Get current user
  User? get currentUser => _auth.currentUser;

  void initialize() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _farmer = null;
      return;
    }

    // Load farmer data from Firestore
    try {
      final farmerDoc = await FarmerService().getfarmersData(user.uid);
      final data = farmerDoc.data() as Map<String, dynamic>?;
      String farmName = data?['farmName'] ?? 'Farm name not provided';
      String farmerName = '';
      String radaRegistrationNumber = '';
      String locationName = '';
      GeoPoint location = const GeoPoint(0, 0);
      String? profileImageUrl;

      if (farmerDoc.exists) {
        final data = farmerDoc.data() as Map<String, dynamic>?;
        farmName = data?['farmName'] ?? 'Farm name not provided';
        farmerName = data?['farmerName'] ?? '';
        radaRegistrationNumber = data?['radaRegistrationNumber'] ?? '';
        locationName = data?['locationName'] ?? '';
        location = data?['location'] ?? const GeoPoint(0, 0);
        profileImageUrl = data?['profileImageUrl'];
      }

      _farmer = Farmer(
        farmName: farmName,
        id: user.uid,
        email: user.email ?? '',
        farmerName: farmerName,
        radaRegistrationNumber: radaRegistrationNumber,
        locationName: locationName,
        location: location,
        profileImageUrl: profileImageUrl,
        isBanned: data?['isBanned'] ?? false,
        isFlagged: data?['isFlagged'] ?? false,
      );
    } catch (e) {
      // If there's an error loading farmer data, create farmer with basic info
      _farmer = Farmer(
        farmName: '',
        id: user.uid,
        email: user.email ?? '',
        farmerName: '',
        radaRegistrationNumber: '',
        locationName: '',
        location: const GeoPoint(0, 0),
        profileImageUrl: null,
        isBanned: false,
        isFlagged: false,
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(
    String email,
    String password, {
    required String farmerName,
    required String radaRegistrationNumber,
    required String locationName,
    required GeoPoint location,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      // Create farmersData doc in 'farmersData' collection only
      await FarmerService().createfarmersData(
        farmerId: user.uid,
        farmerName: farmerName,
        farmName: '', // Provide the farm name here or pass as parameter
        email: email,
        radaRegistrationNumber: radaRegistrationNumber,
        location: location,
        locationName: locationName,
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Add method to refresh farmer data after updates
  Future<void> refreshFarmerData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _onAuthStateChanged(user);
    }
  }
}
