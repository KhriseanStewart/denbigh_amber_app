import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/multi_farmer_product_service.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Helper class to store product info with farmer count
class ProductInfo {
  final QueryDocumentSnapshot product;
  int farmerCount;

  ProductInfo({required this.product, required this.farmerCount});
}

class FarmersSellingProductScreen extends StatelessWidget {
  final String productName;

  const FarmersSellingProductScreen({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Farmers selling "$productName"',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: MultiFarmerProductService().getFarmersSellingProduct(
          productName,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No farmers selling "$productName" found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!;

          // Group products by category, then by name
          final Map<String, Map<String, ProductInfo>> categorizedProducts = {};

          for (final product in products) {
            final data = product.data() as Map<String, dynamic>;
            final category = data['category'] ?? 'Other';
            final name = data['name'] ?? 'Unknown Product';

            // Initialize category if not exists
            if (!categorizedProducts.containsKey(category)) {
              categorizedProducts[category] = {};
            }

            // Initialize product if not exists
            if (!categorizedProducts[category]!.containsKey(name)) {
              categorizedProducts[category]![name] = ProductInfo(
                product: product,
                farmerCount: 0,
              );
            }

            // Increment farmer count
            categorizedProducts[category]![name]!.farmerCount++;
          }

          // Sort categories alphabetically
          final sortedCategories = categorizedProducts.keys.toList()..sort();

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: sortedCategories.length,
            itemBuilder: (context, categoryIndex) {
              final category = sortedCategories[categoryIndex];
              final productsInCategory = categorizedProducts[category]!;

              return CategorySection(
                categoryName: category,
                products: productsInCategory,
              );
            },
          );
        },
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final String categoryName;
  final Map<String, ProductInfo> products;

  const CategorySection({
    super.key,
    required this.categoryName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    // Sort products by name within category
    final sortedProductNames = products.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade300, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(categoryName),
                color: Colors.green.shade700,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${products.length} product${products.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Products in this category
        ...sortedProductNames.map((productName) {
          final productInfo = products[productName]!;
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: UniqueProductCard(
              product: productInfo.product,
              farmerCount: productInfo.farmerCount,
            ),
          );
        }),

        // Spacing between categories
        SizedBox(height: 16),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.eco;
      case 'fruits':
        return Icons.apple;
      case 'grains':
        return Icons.grain;
      case 'dairy':
        return Icons.local_drink;
      case 'meat':
        return Icons.restaurant;
      case 'poultry':
        return Icons.egg;
      default:
        return Icons.category;
    }
  }
}

class UniqueProductCard extends StatelessWidget {
  final QueryDocumentSnapshot product;
  final int farmerCount;

  const UniqueProductCard({
    super.key,
    required this.product,
    required this.farmerCount,
  });

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    final productName = data['name'] ?? 'Unknown Product';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.green.withOpacity(0.15), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to screen showing all farmers selling this product
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MultipleFarmersScreen(productName: productName),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: data['imageUrl'] != null
                        ? Image.network(
                            data['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.green.shade50,
                                  child: Icon(
                                    Icons.eco,
                                    size: 40,
                                    color: Colors.green.shade400,
                                  ),
                                ),
                          )
                        : Container(
                            child: Icon(
                              Icons.eco,
                              size: 40,
                              color: Colors.green.shade400,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Category Badge
                      if (data['category'] != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            data['category'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                      ],

                      // Farmer count and availability
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.groups, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              '$farmerCount farmer${farmerCount > 1 ? 's' : ''} selling',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Tap indicator
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 14,
                            color: Colors.blue.shade600,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tap to view all farmers',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.blue.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow indicator
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MultipleFarmersScreen extends StatelessWidget {
  final String productName;

  const MultipleFarmersScreen({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Farmers selling "$productName"',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: MultiFarmerProductService().getFarmersSellingProduct(
          productName,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No farmers selling "$productName" found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return FarmerProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}

class FarmerProductCard extends StatelessWidget {
  final QueryDocumentSnapshot product;

  const FarmerProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    final formatter = NumberFormat('#,###');

    final price = data['price'] ?? 0;
    final formattedPrice = formatter.format(price);

    final farmerId = data['farmerId'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to product detail screen
          Navigator.pushNamed(
            context,
            AppRouter.productdetail,
            arguments: product,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: data['imageUrl'] != null
                      ? Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
              SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      data['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Farmer Info
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('farmersData')
                          .doc(farmerId)
                          .get(),
                      builder: (context, farmerSnapshot) {
                        String farmerName = 'Unknown Farmer';
                        if (farmerSnapshot.hasData &&
                            farmerSnapshot.data!.exists) {
                          final farmerData =
                              farmerSnapshot.data!.data()
                                  as Map<String, dynamic>?;

                          // Safely get farmer name from different possible field names
                          final nameField = farmerData?['name'];
                          final firstNameField = farmerData?['firstName'];
                          final farmerNameField = farmerData?['farmerName'];

                          // Ensure we get a string, not a list
                          if (nameField != null && nameField is String) {
                            farmerName = nameField;
                          } else if (firstNameField != null &&
                              firstNameField is String) {
                            farmerName = firstNameField;
                          } else if (farmerNameField != null &&
                              farmerNameField is String) {
                            farmerName = farmerNameField;
                          }
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Farmer: $farmerName',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),

                    // Price and Unit
                    Row(
                      children: [
                        Text(
                          '\$$formattedPrice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                        Text(
                          '/${data['unitType'] ?? 'unit'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    // Category and Stock
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (data['category'] != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              data['category'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                        if (data['quantity'] != null)
                          Text(
                            'Stock: ${data['quantity']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price comparison indicator (if multiple farmers)
              Icon(Icons.compare_arrows, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
