import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  /// Create a new user profile (or overwrite an existing one).
  /// Call this right after signup (email or Google).
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String role, // 'customer', 'farmer', or 'admin'
    String? displayName,
    String? photoUrl,
  }) {
    return _users.doc(uid).set({
      'email': email,
      'role': role,
      'displayName': displayName ?? '',
      'photoUrl': photoUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch the user’s profile document.
  Future<DocumentSnapshot> getUserProfile(String uid) {
    return _users.doc(uid).get();
  }

  /// Update only the fields you pass in.
  /// E.g. to change displayName or photoUrl.
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    Map<String, dynamic> updateData = {};
    if (displayName != null) updateData['displayName'] = displayName;
    if (photoUrl != null) updateData['photoUrl'] = photoUrl;
    if (updateData.isNotEmpty) {
      await _users.doc(uid).update(updateData);
    }
  }
}