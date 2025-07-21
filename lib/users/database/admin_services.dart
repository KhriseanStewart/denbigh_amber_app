import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing the “adminsData” collection.
/// Each admin doc has:
///  • userId      — the admin’s Auth UID
///  • accessLevel — e.g. "super-admin", "manager"
///  • permissions — optional list of granular rights
///  • createdAt   — server timestamp when account was created
///  • lastLogin   — optional timestamp of most recent login
class AdminService {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'adminsData',
  );

  /// Create or overwrite an admin record.
  /// Call this right after signup (when role == 'admin').
  Future<void> createAdminData({
    required String uid,
    required String accessLevel,
    List<String>? permissions,
  }) {
    return _col.doc(uid).set({
      'userId': uid,
      'accessLevel': accessLevel,
      'permissions': permissions ?? [],
      'createdAt': FieldValue.serverTimestamp(),
      // 'lastLogin': FieldValue.serverTimestamp(), // uncomment if you want to stamp login
    });
  }

  /// Read a single admin’s data.
  Future<DocumentSnapshot> getAdminData(String uid) {
    return _col.doc(uid).get();
  }

  /// Update only the fields you pass in.
  /// E.g. change accessLevel, add/remove permissions, stamp lastLogin, etc.
  Future<void> updateAdminData({
    required String uid,
    String? accessLevel,
    List<String>? permissions,
    bool updateLastLogin = false,
  }) {
    final updates = <String, dynamic>{};

    if (accessLevel != null) updates['accessLevel'] = accessLevel;
    if (permissions != null) updates['permissions'] = permissions;
    if (updateLastLogin) updates['lastLogin'] = FieldValue.serverTimestamp();

    return _col.doc(uid).update(updates);
  }
}
