import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/dashboard/home.dart';
import '../auth/signin_screen.dart';
import '../auth/signup_screen.dart';

class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _user;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot>? _profileSub;
  String? _role;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() => _user = u);
      if (u != null) {
        _profileSub?.cancel();
        _profileSub = FirebaseFirestore.instance
            .collection('users')
            .doc(u.uid)
            .snapshots()
            .listen((snap) {
              final data = snap.data()!;
              setState(() => _role = data['role'] as String);
            });
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }

  //this will change later on when the screens are made
  /// Returns the appropriate screen based on user role
  @override
  Widget build(BuildContext ctx) {
    if (_user == null) {
      return SignInScreen();
    }
    switch (_role) {
      case 'customer':
        return HomeScreen(); // Replace with actual customer home screen
      case 'farmer':
        return HomeScreen(); // Replace with actual farmer home screen
      case 'admin':
        return HomeScreen(); // Replace with actual admin dashboard
      case 'superadmin':
        return HomeScreen(); // Replace with actual superadmin dashboard
      default:
        return HomeScreen(); // Replace with a waiting screen or error
    }
  }
}
