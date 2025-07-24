import 'package:denbigh_app/farmers/screens/dashboard.dart';
import 'package:denbigh_app/farmers/screens/sales_management.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/widgets/order_badge.dart';
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        // appBar: CustomAppBar(
        //   color: Colors.white,
        //   title: ['Dashboard', 'Sales and Orders Management'][_selectedIndex],
        // ),
        body: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [DashboardScreen(), SalesManagementPage()],
        ),
        bottomNavigationBar: StylishBottomBar(
          elevation: 6,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          backgroundColor: Colors.white,
          option: BubbleBarOptions(
            // barStyle: BubbleBarStyle.vertical,
            borderRadius: BorderRadius.circular(30),
            barStyle: BubbleBarStyle.horizontal,
            bubbleFillStyle: BubbleFillStyle.fill,
            // bubbleFillStyle: BubbleFillStyle.outlined,
            opacity: 0.3,
          ),
          iconSpace: 12.0,
          items: [
            BottomBarItem(
              icon: Icon(Icons.home),
              selectedIcon: Icon(Icons.home_filled),
              title: Text('Dashboard'),
              backgroundColor: Colors.grey[600],
              unSelectedColor: Colors.black,
            ),

            BottomBarItem(
              icon: Icon(Icons.shopping_cart),
              selectedIcon: Icon(Icons.shopping_cart_outlined),
              title: Text('Orders'),
              backgroundColor: Colors.grey[600],
              unSelectedColor: Colors.black,
              badge: OrderBadge(),
              badgeColor: Colors.white,
              showBadge:
                  showBadge, // Pass the boolean value instead of the function
            ),
          ],
          hasNotch: true,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              controller.jumpToPage(index);
            });
          },

          // fabLocation: StylishBarFabLocation.end,
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        // floatingActionButton: FloatingActionButton(onPressed: () {}),
      ),
    );
  }
}
// git add .
// git commit -m "your message here"
// git push