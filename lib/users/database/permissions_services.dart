// lib/services/promotion_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_services.dart';
import 'customer_service.dart';
import 'farmer_services.dart';
import 'admin_services.dart';

class PromotionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserService _userSvc = UserService();
  final CustomerService _custSvc = CustomerService();
  final FarmerService _farmSvc = FarmerService();
  final AdminService _adminSvc = AdminService();

  /// Reads the current user’s role from /users/{uid}
  Future<String> _myRole() async {
    final me = _auth.currentUser!;
    final snap = await _userSvc.getUserProfile(me.uid);
    return (snap.data()! as Map<String, dynamic>)['role'] as String;
  }

  /// Ensures the caller is superadmin
  Future<void> _requireSuperadmin() async {
    if (await _myRole() != 'superadmin') {
      throw Exception('Must be superadmin to perform this action');
    }
  }

  /// Change another user’s role, with special rules:
  ///  • To “farmer”: caller must be superadmin and supply a RADA regNo
  ///  • To “admin”:  caller must be superadmin
  ///  • To “customer”:
  ///      – farmers may demote themselves
  ///      – superadmins may demote anyone
  Future<void> changeUserRole({
    required String targetUid,
    required String newRole, // 'customer' | 'farmer' | 'admin'
    // for farmer:
    String? radaRegistrationNumber,
    String? farmName,
    String? farmersAddress,
    GeoPoint? location,
    String? locationName,
    // for customer:
    String? firstName,
    String? lastName,
    String? address,
    GeoPoint? currentLocation,
    // for admin:
    String? accessLevel,
    List<String>? permissions,
  }) async {
    final me = _auth.currentUser!;
    final caller = me.uid;
    final myRole = await _myRole();

    // 1) Authorization logic
    if (newRole == 'farmer') {
      // Only superadmin may grant farmer—and must provide RADA reg no.
      await _requireSuperadmin();
      if (radaRegistrationNumber == null || radaRegistrationNumber.isEmpty) {
        throw Exception('Farmer registration requires a RADA number');
      }
    } else if (newRole == 'admin') {
      // Only superadmin may grant admin
      await _requireSuperadmin();
    } else if (newRole == 'customer') {
      // Farmers may demote themselves; superadmin may demote any target
      if (!((caller == targetUid && myRole == 'farmer') ||
          (myRole == 'superadmin'))) {
        throw Exception('Not authorized to demote user to customer');
      }
    } else {
      throw Exception('Unknown role: $newRole');
    }

    // 2) Update the base /users/{targetUid} doc
    await _db.collection('users').doc(targetUid).update({'role': newRole});

    // 3) Create or overwrite the role‐specific document
    switch (newRole) {
      case 'customer':
        if (firstName == null ||
            lastName == null ||
            address == null ||
            currentLocation == null) {
          throw Exception('Missing customer fields');
        }
        await _custSvc.createCustomerData(
          uid: targetUid,
          firstName: firstName,
          lastName: lastName,
          address: address,
          currentLocation: currentLocation,
        );
        break;

      case 'farmer':
        // RADA reg no. goes into the farmer doc
        if (farmName == null ||
            farmersAddress == null ||
            location == null ||
            locationName == null) {
          throw Exception('Missing farmer fields');
        }
        await _farmSvc.createFarmerData(
          uid: targetUid,
          farmName: farmName,
          farmersAddress: farmersAddress,
          location: location,
          locationName: locationName,
          radaRegistrationNumber: radaRegistrationNumber!,
        );
        break;

      case 'admin':
        if (accessLevel == null) {
          throw Exception('Missing admin accessLevel');
        }
        await _adminSvc.createAdminData(
          uid: targetUid,
          accessLevel: accessLevel,
          permissions: permissions,
        );
        break;
    }
  }
}
