import 'package:denbigh_app/farmers/auth/screen/farmer_login.dart';
import 'package:denbigh_app/farmers/auth/screen/farmer_signup.dart';
import 'package:denbigh_app/farmers/screens/dashboard.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/users/screens/main_layout/main_layout_farmers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FarmerRoutes {
  static const String farmerlogin = "/farmerlogin";
  static const String farmersignup = "/farmersignup";
  static const String farmerdashboard = "/farmerdashboard";
  static const String farmermainlayout = "/farmermainlayout";

  static Map<String, WidgetBuilder> get routes {
    return {
      farmerlogin: (context) => const FarmerLogin(),
      farmersignup: (context) => const FarmerSignUp(),
      farmerdashboard: (context) =>
          ChangeNotifierProvider<farmer_auth.AuthService>(
            create: (_) => farmer_auth.AuthService(),
            child: const DashboardScreen(),
          ),
      farmermainlayout: (context) =>
          ChangeNotifierProvider<farmer_auth.AuthService>(
            create: (_) => farmer_auth.AuthService(),
            child: const FarmerMainLayout(),
          ),
    };
  }
}
