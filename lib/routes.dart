import 'package:denbigh_app/cart_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/';
 
  static const String cart = '/cart';
 

  static Map<String, WidgetBuilder> get routes {
    return {
     
      AppRoutes.cart: (context) => const CartScreen(),
    };
  }
}
