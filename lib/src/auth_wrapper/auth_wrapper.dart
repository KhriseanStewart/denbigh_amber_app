import 'package:denbigh_app/src/auth_wrapper/check_user_role.dart';
import 'package:denbigh_app/src/farmers/screens/dashboard.dart';
import 'package:denbigh_app/src/users/auth/signin_screen.dart';
import 'package:denbigh_app/src/users/screens/dashboard/home.dart';
import 'package:denbigh_app/src/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapperV2 extends StatelessWidget {
  const AuthWrapperV2({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: LoadingScreen());
        }
        if (!snapshot.hasData) {
          return SignInScreen();
        }
        final user = snapshot.data;
        String uid = user!.uid;
        return FutureBuilder(
          future: CheckUserRole().getRole(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: LoadingScreen());
            }
            if (!snapshot.hasData) {
              return SignInScreen();
            }
            final data = snapshot.data;
            switch (data) {
              case 'user':
                return HomeScreen();
              case 'farmer':
                return DashboardScreen();
              case 'unknown':
              default:
                return SignInScreen();
            }
          },
        );
      },
    );
  }
}
