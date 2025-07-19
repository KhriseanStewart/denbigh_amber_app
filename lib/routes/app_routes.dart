import 'package:denbigh_app/auth_wrapper.dart';
import 'package:denbigh_app/routes/farmer_routes.dart';
import 'package:denbigh_app/routes/user_routes.dart';
import 'package:denbigh_app/users/auth/welcome_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  // Shared routes
  static const String intro = "/";
  static const String authwrapper = "/authwrapper";

  static Map<String, WidgetBuilder> get routes {
    return {
      // Shared routes
      intro: (context) => const FarmerWelcomeScreen(),
      authwrapper: (context) => const AuthWrapper(),

      // Farmer routes
      ...FarmerRoutes.routes,

      // User routes
      ...UserRoutes.routes,
    };
  }
}
