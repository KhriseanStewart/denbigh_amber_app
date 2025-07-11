import 'package:denbigh_app/cart_screen.dart';
import 'package:denbigh_app/profile.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/';
 
  static const String cart = '/cart';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
     
      AppRoutes.cart: (context) => const CartScreen(),
      AppRoutes.profile: (context) => const ProfileScreen(),
    };
  }
}
