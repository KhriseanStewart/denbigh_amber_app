import 'package:denbigh_app/users/auth/welcome_screen.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/screens/main_layout/main_layout.dart'
    as user_layout;
import 'package:denbigh_app/users/screens/main_layout/main_layout_farmers.dart'
    as farmer_layout;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If we're waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is not signed in
        if (!snapshot.hasData) {
          return const FarmerWelcomeScreen();
        }

        // If user is signed in, check their role
        return FutureBuilder<String?>(
          future: AuthService().getUserRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Navigate based on role
            final userRole = roleSnapshot.data;
            if (userRole == 'farmer') {
              return const farmer_layout.FarmerMainLayout();
            } else {
              // For users and other roles
              return const user_layout.MainLayout();
            }
          },
        );
      },
    );
  }
}
