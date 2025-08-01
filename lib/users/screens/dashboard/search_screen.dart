import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/product_services.dart';
import 'package:denbigh_app/users/database/multi_farmer_product_service.dart';
import 'package:denbigh_app/users/screens/product_screen/product_card.dart';
import 'package:denbigh_app/users/screens/product_screen/product_screen_tester.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MultiFarmerProductService _multiFarmerService =
      MultiFarmerProductService();

  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _isSearching = value.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: "Search for products...",
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          icon: Icon(FeatherIcons.sliders, size: 28),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (_searchQuery.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.blue.shade600,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Searching for "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _isSearching = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: buildGridViewProducts()),
          ],
        ),
      ),
    );
  }

  Widget buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Icon(FeatherIcons.sliders, size: 28),
          ),
        ),
      ],
    );
  }

  Widget buildGridViewProducts() {
    // Using ProductService().getProducts() as the main stream
    final streamList = ProductService().getProducts();

    return StreamBuilder<QuerySnapshot>(
      stream: streamList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Products Found"));
        }

        final items = snapshot.data!.docs;

        if (_isSearching && _searchQuery.isNotEmpty) {
          // Filter items based on search query
          final filteredItems = items.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final farmerName = (data['farmerName'] ?? '')
                .toString()
                .toLowerCase();
            return name.contains(_searchQuery.toLowerCase()) ||
                farmerName.contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No products found for "$_searchQuery"',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: filteredItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final doc = filteredItems[index];
              final data = doc.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScreenTester(),
                      settings: RouteSettings(arguments: doc),
                    ),
                  );
                },
                child: UserProductCard(data: doc),
              );
            },
          );
        } else {
          // Show all products
          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final doc = items[index];
              final data = doc.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.productdetail,
                    arguments: doc,
                  );
                },
                child: UserProductCard(data: doc),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: Offset(0, 0.5),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child:
                  item['imageUrl'] != null &&
                      (item['imageUrl'] as String).isNotEmpty
                  ? Image.network(
                      item['imageUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported_outlined),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      width: double.infinity,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),

          SizedBox(height: 8),

          // Product Name
          Text(
            item['name'] ?? 'Unknown Product',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 4),

          // Farmer Name
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item['farmerName'] ?? 'Unknown Farmer',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 4),

          // Price
          Text(
            '\$${item['price'] ?? 0}/${item['unitType'] ?? 'unit'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
