// ignore_for_file: use_build_context_synchronously
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/database/customer_service.dart';
import 'package:denbigh_app/users/database/product_services.dart';
import 'package:denbigh_app/users/screens/product_screen/home_product_card.dart';
import 'package:denbigh_app/users/screens/profile/pic_card.dart';
import 'package:denbigh_app/widgets/misc.dart';
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
  double _currentSliderPrice = 100;
  List<String> category = [
    'All',
    'Legumes',
    'Herbs & Spicies',
    'Roots & Tubers',
    'Condiments',
    'Fruits',
    'Vegetable',
  ];
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

  final userData = CustomerService().getUserInformation(auth!.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text("data"));
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
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(150),
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
          children: [
            FutureBuilder(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Text("No document");
                }
                final data = snapshot.data;
                return AppBar(
                  backgroundColor:
                      Colors.transparent, // make AppBar transparent
                  titleSpacing: 10,
                  leading: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: PicCard(),
                  ),
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
                        data!['name'] ?? 'user',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.notificationscreen,
                        );
                      },
                      icon: Icon(FeatherIcons.bell, color: Colors.black),
                    ),
                  ],
                );
              },
            ),
            buildHeader(),
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
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category.length,
                  itemBuilder: (context, index) {
                    final catName = category[index];
                    return Container(
                      margin: EdgeInsets.only(right: 6),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
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
                      value: _currentSliderPrice,
                      min: 100,
                      max: 200000,
                      divisions: 100,
                      label: _currentSliderPrice.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderPrice = value;
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
              DropdownButton<String>(
                value: _selectedValue,
                hint: Text(_selectedValue ?? 'Select Zone'),
                onTap: () {
                  print(_selectedValue);
                },
                items: [
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                  DropdownMenuItem(value: 'zone-one', child: Text('Zone 1')),
                  DropdownMenuItem(value: 'zone-two', child: Text('Zone 2')),
                  DropdownMenuItem(value: 'zone-three', child: Text('Zone 3')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
              ),
              Divider(),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text("Filter"),
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
    final streamList = ProductService().getProducts();

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
              child: ProductCard(data: data),
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
