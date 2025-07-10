// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing the shared “users” collection.
/// Each user doc has:
///  • email       — the user’s email
///  • role        — one of “customer” | “farmer” | “admin”
///  • displayName — full name or chosen display name
///  • photoUrl    — link to their profile picture (optional)
///  • createdAt   — Firestore server timestamp
class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'users',
  );

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
  }) {
    final Map<String, dynamic> updates = {};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    return _users.doc(uid).update(updates);
  }
}
