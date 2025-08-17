import 'package:denbigh_app/src/farmers/screens/dashboard.dart';
import 'package:denbigh_app/src/farmers/screens/sales_management.dart';
import 'package:denbigh_app/src/farmers/screens/settings_screen.dart';
import 'package:denbigh_app/src/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/src/farmers/widgets/order_badge.dart';
import 'package:denbigh_app/src/farmers/widgets/banned_user_widget.dart';
import 'package:flutter/material.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerMainLayout extends StatefulWidget {
  const FarmerMainLayout({super.key});

  @override
  State<FarmerMainLayout> createState() => _FarmerMainLayoutState();
}

class _FarmerMainLayoutState extends State<FarmerMainLayout> {
  @override
  Widget build(BuildContext context) {
    return _MainLayoutContent();
  }
}

class _MainLayoutContent extends StatefulWidget {
  @override
  State<_MainLayoutContent> createState() => _MainLayoutContentState();
}

class _MainLayoutContentState extends State<_MainLayoutContent> {
  PageController controller = PageController(initialPage: 0);
  int _selectedIndex = 0;
  bool showBadge = false;

  @override
  void initState() {
    super.initState();
    // Listen to order changes to update badge visibility
    _listenToOrders();
  }

  void _listenToOrders() {
    // Get the auth service to get farmer ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = farmer_auth.AuthService();
      if (auth.farmer != null) {
        // Listen to orders stream
        FirebaseFirestore.instance
            .collection('orders')
            .where('farmerId', isEqualTo: auth.farmer!.id)
            .where('status', isEqualTo: 'processing')
            .snapshots()
            .listen((snapshot) {
              // Check if there are any valid orders
              bool hasValidOrders = false;
              if (snapshot.docs.isNotEmpty) {
                for (final doc in snapshot.docs) {
                  final orderData = doc.data();
                  final orderId = orderData['orderId'] as String? ?? '';
                  if (orderId.isNotEmpty) {
                    hasValidOrders = true;
                    break;
                  }
                }
              }

              // Update showBadge with if statement logic
              if (mounted) {
                setState(() {
                  showBadge =
                      hasValidOrders; // This is the if statement you wanted
                });
              }
            });
      }
    });
  }

  // final CartService cartService = CartService();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = farmer_auth.AuthService();

    // Check if farmer is banned and show banned widget instead of normal layout
    if (auth.farmer != null && auth.farmer!.isBanned) {
      return BannedUserWidget();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF8FBF8), // Light green background
        body: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            DashboardScreen(),
            SalesManagementPage(),
            FarmerSettingsScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.95), Colors.white],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, -5),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, -3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: StylishBottomBar(
            elevation:
                0, // Remove default elevation since we're using custom shadow
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            backgroundColor: Colors.transparent,
            option: BubbleBarOptions(
              borderRadius: BorderRadius.circular(25),
              barStyle: BubbleBarStyle.horizontal,
              bubbleFillStyle: BubbleFillStyle.fill,
              opacity: 0.15,
            ),
            iconSpace: 15.0,
            items: [
              BottomBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.dashboard_rounded, size: 24),
                ),
                selectedIcon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 0
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: Color(0xFF4CAF50),
                unSelectedColor: Colors.grey.shade600,
              ),
              BottomBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.analytics_rounded, size: 24),
                ),
                selectedIcon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Orders',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 1
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: Color(0xFF4CAF50),
                unSelectedColor: Colors.grey.shade600,
                badge: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFE55353)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: OrderBadge(),
                ),
                badgeColor: Colors.transparent,
                showBadge: showBadge,
              ),
              BottomBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.settings_rounded, size: 24),
                ),
                selectedIcon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 2
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: Color(0xFF4CAF50),
                unSelectedColor: Colors.grey.shade600,
              ),
            ],
            hasNotch: false, // Cleaner look without notch
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                controller.jumpToPage(index);
              });
            },
          ),
        ),
      ),
    );
  }
}
// git add .
// git commit -m "your message here"
// git push