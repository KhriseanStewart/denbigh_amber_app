import 'package:denbigh_app/auth_wrapper.dart';
import 'package:denbigh_app/farmers/auth/screen/farmer_login.dart';
import 'package:denbigh_app/farmers/auth/screen/farmer_signup.dart';
import 'package:denbigh_app/farmers/screens/dashboard.dart';

import 'package:denbigh_app/users/auth/signin_screen.dart';
import 'package:denbigh_app/users/auth/signup_screen.dart';
import 'package:denbigh_app/users/auth/welcome_screen.dart';
import 'package:denbigh_app/users/screens/cart_screen/cart_screen.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:denbigh_app/users/screens/dashboard/search_screen.dart';
import 'package:denbigh_app/users/screens/dashboard/view_all_items.dart';
import 'package:denbigh_app/users/screens/main_layout/main_layout.dart';
import 'package:denbigh_app/users/screens/main_layout/main_layout_farmers.dart';

import 'package:denbigh_app/users/screens/orders/user_orders_screen.dart';
import 'package:denbigh_app/users/screens/product_screen/product_screen.dart';
import 'package:denbigh_app/users/screens/profile/account_information_screen.dart';
import 'package:denbigh_app/users/screens/profile/credit_card_screen.dart';
import 'package:denbigh_app/users/screens/profile/profile.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String intro = "/";
  static const String authwrapper = "/authwrapper";
  static const String login = "/login";
  static const String signUp = "/SignUp";

  static const String farmerlogin = "/farmerlogin";
  static const String farmersignup = "/farmersignup";
  static const String farmerdashboard = "/farmerdashboard";

  static const String homepage = "/homepage";
  static const String cartpage = "/cartpage";

  static const String mainlayout = "/mainlayout";
  static const String profile = '/profile';
  static const String card = '/card';
  static const String productdetail = '/productdetail';
  static const String accountInformation = '/account-information';
  static const String searchscreen = '/searchscreen';

  static const String viewallitem = '/viewallitem';
  static const String userorders = '/userorders';
  static const String farmermainlayout = '/farmerMainLayout';

  static Map<String, WidgetBuilder> get routes {
    return {
      intro: (context) => const FarmerWelcomeScreen(),
      authwrapper: (context) => const AuthWrapper(),
      login: (context) => const SignInScreen(),
      signUp: (context) => const SignUpScreen(),

      farmerlogin: (context) => const FarmerLogin(),
      farmersignup: (context) => const FarmerSignUp(),
      farmerdashboard: (context) => const DashboardScreen(),

      homepage: (context) => const HomeScreen(),
      cartpage: (context) => const CartScreen(),
      mainlayout: (context) => const MainLayout(),
      farmermainlayout: (context) => const FarmerMainLayout(),

      accountInformation: (context) => const AccountInformationScreen(),
      profile: (context) => const ProfileScreen(),
      card: (context) => const CardScreen(),
      searchscreen: (context) => const SearchScreen(),

      viewallitem: (context) => const ViewAllItems(),
      userorders: (context) => const UserOrdersScreen(),
      productdetail: (context) => const ProductScreen(),
    };
  }
}
