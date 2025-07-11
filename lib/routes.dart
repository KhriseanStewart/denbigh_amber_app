import 'package:denbigh_app/screens/cart_screen/cart_screen.dart';
import 'package:denbigh_app/screens/dashboard/home.dart';
import 'package:denbigh_app/screens/main_layout/main_layout.dart';
import 'package:denbigh_app/screens/notification/notification_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String intro = "/";
  static const String homepage = "/homepage";
  static const String cartpage = "/cartpage";
  static const String notificationscreen = "/notificationscreen";
  static const String mainlayout = "/mainlayout";

  static Map<String, WidgetBuilder> get routes {
    return {
      homepage: (context) => const HomeScreen(),
      cartpage: (context) => const CartScreen(),
      mainlayout: (context) => const MainLayout(),
      notificationscreen: (context) => const NotificationScreen(),
      };
  }
}
