import 'package:denbigh_app/users/screens/cart_screen/cart_screen.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:denbigh_app/users/screens/profile/profile.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  List<Widget> _screen = [HomeScreen(), CartScreen(), ProfileScreen()];
  int _currentIndex = 0;
  void onTap(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_currentIndex],
      bottomNavigationBar: StylishBottomBar(
        onTap: onTap,
        currentIndex: _currentIndex,
        items: [
          BottomBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomBarItem(icon: Icon(FeatherIcons.truck), title: Text("Cart")),
          BottomBarItem(icon: Icon(FeatherIcons.user), title: Text("Profile")),
        ],
        option: DotBarOptions(),
      ),
    );
  }
}
