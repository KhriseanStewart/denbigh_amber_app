
import 'package:denbigh_app/src/users/auth/welcome_screen.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  static const String login = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getroutes() {
    return {
      login: (context) => const  FarmerWelcomeScreen(), 
    };
  }
}
