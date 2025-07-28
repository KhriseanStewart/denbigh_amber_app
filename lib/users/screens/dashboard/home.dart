// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/database/customer_service.dart'
    hide AuthService;

import 'package:denbigh_app/users/screens/product_screen/product_card.dart';
import 'package:denbigh_app/users/screens/profile/pic_card.dart';
import 'package:denbigh_app/widgets/misc.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final auth = AuthService().currentUser;

class _HomeScreenState extends State<HomeScreen> {
  String? _categoryFilter = 'All'; // default category
  double _maxPriceFilter = 200000; // max price filter
  String? _deliveryZoneFilter = 'default'; // delivery zone filter
  final double _currentSliderPrice = 100;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = 'default';
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.green),
    );
  }

  Future<void> onRefresh() async {
    setState(() {
      //TODO: UPDATE UI IF REFRESHED
    });
  }

  // Safely get user data with null check
  Future<DocumentSnapshot?> getUserData() async {
    if (auth?.uid != null) {
      try {
        return await CustomerService().getUserInformation(auth!.uid);
      } catch (e) {
        print('Error fetching user data: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 4. Get all products for a farmer in a category

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text("Please sign in"));
        }
        return buildUserHome(context);
      },
    );
  }

  Widget buildUserHome(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: hexToColor("F4F6F8"),
      drawerEnableOpenDragGesture: false,
      endDrawer: buildEndDrawer(),
   
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: buildFilterRow(),
                ),
                SizedBox(height: 4),
                Expanded(child: buildGridViewProducts()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(200), // Increased from 150 to 200
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), // adjust opacity here
              BlendMode.darken, // or use BlendMode.srcOver
            ),
            fit: BoxFit.cover,
            image: AssetImage('assets/images/header_background_dashboard.jpeg'),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Added this to prevent overflow
          children: [
            Flexible(
              // Wrapped in Flexible to prevent overflow
              child: FutureBuilder<DocumentSnapshot?>(
                future: getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return AppBar(
                      backgroundColor: Colors.transparent,
                      titleSpacing: 10,
                      leading: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: PicCard(),
                      ),
                      actions: [Container()],
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName ??
                                FirebaseAuth.instance.currentUser?.email
                                    ?.split('@')
                                    .first ??
                                "User",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      !snapshot.data!.exists) {
                    return AppBar(
                      backgroundColor: Colors.transparent,
                      titleSpacing: 10,
                      leading: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: PicCard(),
                      ),
                      actions: [Container()],
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName ??
                                FirebaseAuth.instance.currentUser?.email
                                    ?.split('@')
                                    .first ??
                                "User",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  return AppBar(
                    backgroundColor:
                        Colors.transparent, // make AppBar transparent
                    titleSpacing: 10,
                    leading: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: PicCard(),
                    ),
                    actions: [Container()],
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          data?['name'] ??
                              data?['firstName'] ??
                              FirebaseAuth.instance.currentUser?.displayName ??
                              FirebaseAuth.instance.currentUser?.email
                                  ?.split('@')
                                  .first ??
                              'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Flexible(
              // Wrapped in Flexible to prevent overflow
              child: buildHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEndDrawer() {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Filter",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ListTile(
                title: Text(
                  "Category",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 40, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final catName = categories[index];
                    final isSelected = _categoryFilter == catName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _categoryFilter = catName;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 6),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.black,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            catName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  "Price",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Text(
                    "\$${_currentSliderPrice.round().toString()}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _maxPriceFilter,
                      min: 100,
                      max: 200000,
                      divisions: 100,
                      label: _maxPriceFilter.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _maxPriceFilter = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              ListTile(
                title: Text(
                  "Delivery",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Delivery zone dropdown
              DropdownButton<String>(
                value: _deliveryZoneFilter,
                items: [
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                  DropdownMenuItem(value: 'zone-one', child: Text('Zone 1')),
                  DropdownMenuItem(value: 'zone-two', child: Text('Zone 2')),
                  DropdownMenuItem(value: 'zone-three', child: Text('Zone 3')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _deliveryZoneFilter = newValue;
                  });
                },
              ),
              Divider(),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text("Apply Filter"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridViewProducts() {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 4) / 2;
    final itemHeight = itemWidth * 1.55; // or a fixed ratio

    Stream<QuerySnapshot> getFilteredProducts() {
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );

      // Apply category filter
      Query query = productsRef;
      if (_categoryFilter != null && _categoryFilter != 'All') {
        query = query.where('category', isEqualTo: _categoryFilter);
      }

      // Apply price filter
      query = query.where('price', isLessThanOrEqualTo: _maxPriceFilter);

      // Apply delivery zone filter (assuming delivery zone info is stored in 'deliveryZone' field)
      if (_deliveryZoneFilter != null && _deliveryZoneFilter != 'default') {
        query = query.where('deliveryZone', isEqualTo: _deliveryZoneFilter);
      }

      return query.snapshots();
    }

    final streamList = getFilteredProducts();

    return StreamBuilder(
      stream: streamList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text("No Products"));
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final productdata = snapshot.data!.docs;
        return GridView.builder(
          itemCount: productdata.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemBuilder: (context, index) {
            final data = productdata[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.productdetail,
                  arguments: data,
                );
              },
              child: UserProductCard(data: data),
            );
          },
        );
      },
    );
  }

  Widget buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: Row(
              spacing: 6,
              children: [Icon(Icons.filter_list, size: 28), Text('Filter')],
            ),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.viewallitem);
          },
          child: Text("View All", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            onTap: () {
              Navigator.pushNamed(context, AppRouter.searchscreen);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
              hint: Row(children: [Icon(Icons.search), Text("Search...")]),
            ),
          ),
        ],
      ),
    );
  }
}
