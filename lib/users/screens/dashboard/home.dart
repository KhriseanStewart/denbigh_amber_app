import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/auth_service.dart';
import 'package:denbigh_app/users/database/customer_service.dart'
    hide AuthService;
import 'package:denbigh_app/users/database/product_services.dart';
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
  double _currentSliderPrice = 100;
  List<String> category = ['All', ...categories];
  String? _selectedValue;
  String _selectedCategory = 'All';

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
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category.length,
                  itemBuilder: (context, index) {
                    final catName = category[index];
                    final isSelected = _selectedCategory == catName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = catName;
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

        // Filter products based on selected category
        List<QueryDocumentSnapshot> filteredProducts = productdata;
        if (_selectedCategory != 'All') {
          filteredProducts = productdata.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final productCategories = data['category'] as List<dynamic>?;
            return productCategories?.contains(_selectedCategory) ?? false;
          }).toList();
        }

        // Group products by category, then by name to avoid duplicates
        Map<String, Map<String, QueryDocumentSnapshot>> groupedProducts = {};
        Map<String, Map<String, int>> farmerCounts = {};

        if (_selectedCategory == 'All') {
          // Group all products by their categories, then by name
          for (var doc in filteredProducts) {
            final data = doc.data() as Map<String, dynamic>;
            final productCategories = data['category'] as List<dynamic>?;
            final productName = data['name'] ?? 'Unknown Product';

            String categoryName = 'Other';
            if (productCategories != null && productCategories.isNotEmpty) {
              categoryName = productCategories.first.toString();
            }

            // Initialize category if not exists
            if (!groupedProducts.containsKey(categoryName)) {
              groupedProducts[categoryName] = {};
              farmerCounts[categoryName] = {};
            }

            // Count farmers selling this product
            farmerCounts[categoryName]![productName] =
                (farmerCounts[categoryName]![productName] ?? 0) + 1;

            // Keep the first occurrence of each product name
            if (!groupedProducts[categoryName]!.containsKey(productName)) {
              groupedProducts[categoryName]![productName] = doc;
            }
          }
        } else {
          // Show only the selected category, grouped by name
          groupedProducts[_selectedCategory] = {};
          farmerCounts[_selectedCategory] = {};

          for (var doc in filteredProducts) {
            final data = doc.data() as Map<String, dynamic>;
            final productName = data['name'] ?? 'Unknown Product';

            // Count farmers selling this product
            farmerCounts[_selectedCategory]![productName] =
                (farmerCounts[_selectedCategory]![productName] ?? 0) + 1;

            // Keep the first occurrence of each product name
            if (!groupedProducts[_selectedCategory]!.containsKey(productName)) {
              groupedProducts[_selectedCategory]![productName] = doc;
            }
          }
        }

        if (groupedProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No products found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (_selectedCategory != 'All')
                  Text(
                    "in $_selectedCategory category",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: groupedProducts.keys.length,
          itemBuilder: (context, categoryIndex) {
            final categoryName = groupedProducts.keys.elementAt(categoryIndex);
            final categoryProducts = groupedProducts[categoryName]!;
            final categoryFarmerCounts = farmerCounts[categoryName]!;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category header (only show when displaying all categories)
                  if (_selectedCategory == 'All')
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "${categoryProducts.length} unique product${categoryProducts.length > 1 ? 's' : ''}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Category filter header when specific category is selected
                  if (_selectedCategory != 'All')
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _selectedCategory,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Text(
                            "${categoryProducts.length} unique product${categoryProducts.length > 1 ? 's' : ''}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All';
                              });
                            },
                            child: Text(
                              "View All",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Products grid for this category
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: categoryProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, productIndex) {
                      final productName = categoryProducts.keys.elementAt(
                        productIndex,
                      );
                      final data = categoryProducts[productName]!;
                      final farmerCount =
                          categoryFarmerCounts[productName] ?? 1;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.productfarmersselection,
                            arguments: productName,
                          );
                        },
                        child: DashboardProductCard(
                          data: data,
                          farmerCount: farmerCount,
                        ),
                      );
                    },
                  ),

                  // Add spacing between categories
                  if (_selectedCategory == 'All' &&
                      categoryIndex < groupedProducts.keys.length - 1)
                    SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildFilterRow() {
    return Column(
      children: [
        // Category filter chips
        Container(
          height: 40,
          margin: EdgeInsets.only(bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: category.length,
            itemBuilder: (context, index) {
              final catName = category[index];
              final isSelected = _selectedCategory == catName;
              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(catName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = catName;
                    });
                  },
                  selectedColor: Colors.green.withOpacity(0.2),
                  checkmarkColor: Colors.green,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.green : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        // Original filter row
        Row(
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

class DashboardProductCard extends StatelessWidget {
  final QueryDocumentSnapshot data;
  final int farmerCount;

  const DashboardProductCard({
    super.key,
    required this.data,
    required this.farmerCount,
  });

  @override
  Widget build(BuildContext context) {
    final productData = data.data() as Map<String, dynamic>;
    final productName = productData['name'] ?? 'Unknown Product';
    final imageUrl = productData['imageUrl'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.green.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with overlay
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.green.shade50,
                                  child: Icon(
                                    Icons.eco,
                                    size: 50,
                                    color: Colors.green.shade300,
                                  ),
                                ),
                          )
                        : Container(
                            child: Icon(
                              Icons.eco,
                              size: 50,
                              color: Colors.green.shade300,
                            ),
                          ),
                  ),
                ),
                // Farmer count badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.groups, size: 12, color: Colors.white),
                        SizedBox(width: 2),
                        Text(
                          '$farmerCount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Info Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Bottom section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farmers selling text
                      Text(
                        '$farmerCount farmer${farmerCount > 1 ? 's' : ''} selling',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Tap indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Tap to compare',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
