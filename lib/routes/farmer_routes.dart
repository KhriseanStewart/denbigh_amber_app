import 'package:denbigh_app/src/farmers/auth/screen/farmer_login.dart';
import 'package:denbigh_app/src/farmers/auth/screen/farmer_signup.dart';
import 'package:denbigh_app/src/farmers/screens/dashboard.dart';

import 'package:denbigh_app/src/users/screens/main_layout/main_layout_farmers.dart';
import 'package:flutter/material.dart';


class FarmerRoutes {
  static const String farmerlogin = "/farmerlogin";
  static const String farmersignup = "/farmersignup";
  static const String farmerdashboard = "/farmerdashboard";
  static const String farmermainlayout = "/farmermainlayout";

  static Map<String, WidgetBuilder> get routes {
    return {
      farmerlogin: (context) => const FarmerLogin(),
      farmersignup: (context) => const FarmerSignUp(),
      farmerdashboard: (context) => const DashboardScreen(),
      farmermainlayout: (context) => const FarmerMainLayout(),
    };
  }
}
