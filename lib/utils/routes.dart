import 'package:denbigh_app/screens/profile/account_information_screen.dart';
import 'package:denbigh_app/screens/profile/credit_card_screen.dart' show CardScreen;
import 'package:denbigh_app/screens/cart_screen/cart_screen.dart';
import 'package:denbigh_app/screens/profile/profile.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/';
 
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String card = '/card';
  static const String accountInformation = '/account-information';

  static Map<String, WidgetBuilder> get routes {
    return {
     
      AppRoutes.cart: (context) => const CartScreen(),
      AppRoutes.profile: (context) => const ProfileScreen(),
      AppRoutes.card: (context) => const CardScreen(),
      AppRoutes.accountInformation: (context) => const AccountInformationScreen(),
    };
  }
}
