// VADO
// User authentication service with Firebase

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<bool?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true; // Returns user object if successful
    } catch (e) {
      print("Error signing in: $e");
      return null; // Returns null if sign-in fails
    }
  }

  // Sign in with Google using Firebase
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );
      return userCredential.user; // Returns user object if successful
    } catch (e) {
      print("Error signing in with Google: $e");
      return null; // Returns null if sign-in fails
    }
  }

  /// Register with email/password *and* set the user’s role in Firestore
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String role, // 'customer', 'farmer', or 'admin'
    required String name,
    required String location,
    String? farmerId, // Optional RADA ID for farmers
  }) async {
    try {
      // 1️⃣ Create the Auth user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // 2️⃣ Prepare user data
      Map<String, dynamic> userData = {
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'name': name,
        'location': location,
      };

      // Add farmerId/RADA ID if provided (for farmers)
      if (farmerId != null && farmerId.isNotEmpty) {
        userData['farmerId'] = uid;
        userData['radaRegistrationNumber'] =
            farmerId; // Also store as radaId for clarity
      }

      // 3️⃣ Write their profile, including role
      await _db.collection('farmersData').doc(uid).set(userData);

      return cred.user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  //Add away to update email later
  Future<void> updateInformation({
    required String uid,
    required String name,
    required String location,
    required String telephone,
  }) async {
    try {
      await _db.collection('farmersData').doc(uid).update({
        'createdAt': FieldValue.serverTimestamp(),
        'name': name,
        'location': location,
        'telephone': telephone,
      });
    } catch (e) {
      print(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  /// Re-authenticates the user, then updates their password.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 1️⃣ Re-authenticate
      await user.reauthenticateWithCredential(cred);

      // 2️⃣ Update to the new password
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      print('Password change failed: $e');
      return false;
    }
  }

  /// Sends a password-reset email to the given address.
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }
}
