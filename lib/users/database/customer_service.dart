// lib/services/customer_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerService {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'customersData',
  );
  final _ref = FirebaseFirestore.instance;

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

  Future<DocumentSnapshot> getUserInformation(String uid) async {
    return _ref.collection("users").doc(uid).get();
  }

  /// Fetches the customer’s data
  Future<DocumentSnapshot> getCustomerData(String uid) {
    return _col.doc(uid).get();
  }
}

// Create a single, unified AuthService
class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password for both customers and farmers
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType, // 'customer' or 'farmer'
    String? farmName,
    String? farmLocation,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      Map<String, dynamic> userData = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add farmer-specific fields
      if (userType == 'farmer') {
        userData['farmName'] = farmName;
        userData['farmLocation'] = farmLocation;
      }

      await _firestore.collection('users').doc(result.user!.uid).set(userData);

      // Create type-specific data
      if (userType == 'customer') {
        final customerService = CustomerService();
        await customerService.createCustomerData(
          uid: result.user!.uid,
          firstName: firstName,
          lastName: lastName,
          address: null,
          currentLocation: null,
        );
      } else if (userType == 'farmer') {
        await _createFarmerData(
          uid: result.user!.uid,
          firstName: firstName,
          lastName: lastName,
          farmName: farmName,
          farmLocation: farmLocation,
        );
      }

      notifyListeners();
      return result;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Sign Up');
      return null;
    }
  }

  // Create farmer-specific data
  Future<void> _createFarmerData({
    required String uid,
    required String firstName,
    required String lastName,
    String? farmName,
    String? farmLocation,
  }) async {
    await _firestore.collection('farmersData').doc(uid).set({
      'userId': uid,
      'firstName': firstName,
      'lastName': lastName,
      'farmName': farmName,
      'farmLocation': farmLocation,
      'joinedAt': FieldValue.serverTimestamp(),
      'isVerified': false,
      'products': [],
    });
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return result;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Sign In');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Sign Out');
    }
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.data() != null
          ? (doc.data() as Map<String, dynamic>)['userType']
          : null;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Get User Role');
      return null;
    }
  }

  // Get farmer data
  Future<DocumentSnapshot> getFarmerData(String uid) {
    return _firestore.collection('farmersData').doc(uid).get();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Password Reset');
    }
  }

  // Check if user is authenticated and get their type
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Get Current User Data');
      return null;
    }
  }
}

// Create a centralized error handler
class ErrorHandler {
  static void handleError(dynamic error, {String? context}) {
    String errorMessage = 'An error occurred';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = error.message ?? 'Authentication failed.';
      }
    } else if (error is FirebaseException) {
      errorMessage = error.message ?? 'Database error occurred.';
    }

    // Log the error for debugging
    if (kDebugMode) {
      print('Error in $context: $error');
    }

    // You can also show a snackbar or dialog here
    // For now, just print the user-friendly message
    if (kDebugMode) {
      print('User-friendly error: $errorMessage');
    }
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
