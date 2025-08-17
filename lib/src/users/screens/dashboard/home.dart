// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/src/farmers/widgets/used_list/list.dart';
import 'package:denbigh_app/routes/routes.dart';
import 'package:denbigh_app/src/users/database/auth_service.dart';
import 'package:denbigh_app/src/users/database/customer_service.dart'
    hide AuthService;
import 'package:denbigh_app/src/users/screens/chat_feedback_report/chat_hub.dart';
import 'package:denbigh_app/src/users/screens/product_screen/product_card.dart';
import 'package:denbigh_app/src/users/screens/profile/pic_card.dart';
import 'package:denbigh_app/src/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
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
  String _categoryFilter = 'All'; // default category
  String? _deliveryZoneFilter = 'default'; // delivery zone filter
  double _currentSliderPrice = 0;
  TextEditingController _priceFilter = TextEditingController();

  @override
  void initState() {
    super.initState();
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
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, AppRouter.login);
          });
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Feedback or Report Farmer',
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatHub()),
          );
        },
        child: Icon(FeatherIcons.messageCircle, size: 28),
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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
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
                  if (!snapshot.hasData || snapshot.data == null) {
                    return AppBar(
                      backgroundColor: Colors.transparent,
                      title: Text("Welcome User"),
                      centerTitle: true,
                    );
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: AppBar(
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
                                FirebaseAuth
                                    .instance
                                    .currentUser
                                    ?.displayName ??
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
                  Icon(Icons.filter_list, color: Color(0xFF4CAF50), size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Filter",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Category",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final catName = categories[index];
                          final isSelected = _categoryFilter == catName;

                          // Fallback for empty category
                          if (catName.isEmpty) {
                            return Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'No Products Available',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _categoryFilter = catName;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFF4CAF50),
                                          Color(0xFF66BB6A),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF4CAF50)
                                      : Color(0xFF4CAF50).withOpacity(0.5),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  catName.isEmpty ? 'Uncategorized' : catName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Color(0xFF2E7D32),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Price Range",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: '\$100',
                        fillColor: Color(0xFFF1F8E9),
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: _priceFilter,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Delivery zone dropdown
              DropdownButton<String>(
                value: _deliveryZoneFilter,
                items: [
                  DropdownMenuItem(
                    value: 'default',
                    child: Text('Not Available Yet'),
                  ),
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
                      double priceNum = double.parse(_priceFilter.text);
                      _currentSliderPrice = priceNum;
                      print(priceNum);
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
      Query<Map<String, dynamic>> productsRef = FirebaseFirestore.instance
          .collection("products")
          .where('isComplete', isEqualTo: true) // Only show completed products
          .where('isActive', isEqualTo: true);

      // Start with base query
      Query query = productsRef;

      // Apply category filter (arrayContains)
      if (_categoryFilter != 'All') {
        query = query.where('category', arrayContains: _categoryFilter);
      }

      // Apply price filter - show products with price greater than or equal to the slider value
      if (_currentSliderPrice > 0) {
        query = query.where(
          'price',
          isGreaterThanOrEqualTo: _currentSliderPrice,
        );
      }
      print(_currentSliderPrice);

      // Apply delivery zone filter
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
