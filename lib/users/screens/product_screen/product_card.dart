import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/screens/products/farmers_selling_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class UserProductCard extends StatefulWidget {
  final QueryDocumentSnapshot data;
  const UserProductCard({super.key, required this.data});

  @override
  State<UserProductCard> createState() => _UserProductCardState();
}

class _UserProductCardState extends State<UserProductCard> {
  int farmerCount = 1;
  String farmerName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadFarmerInfo();
    _loadFarmerCount();
  }

  void _loadFarmerInfo() async {
    final data = widget.data.data() as Map<String, dynamic>;
    final farmerId = data['farmerId'];

    if (farmerId != null) {
      try {
        final farmerDoc = await FirebaseFirestore.instance
            .collection('farmersData')
            .doc(farmerId)
            .get();

        if (farmerDoc.exists) {
          final farmerData = farmerDoc.data();

          // Safely get farmer name with type checking
          final nameField = farmerData?['name'];
          final firstNameField = farmerData?['firstName'];
          final farmerNameField = farmerData?['farmerName'];

          String safeFarmerName = 'Unknown Farmer';
          if (nameField != null && nameField is String) {
            safeFarmerName = nameField;
          } else if (firstNameField != null && firstNameField is String) {
            safeFarmerName = firstNameField;
          } else if (farmerNameField != null && farmerNameField is String) {
            safeFarmerName = farmerNameField;
          }

          setState(() {
            farmerName = safeFarmerName;
          });
        } else {
          setState(() {
            farmerName = 'Unknown Farmer';
          });
        }
      } catch (e) {
        setState(() {
          farmerName = 'Unknown Farmer';
        });
      }
    } else {
      setState(() {
        farmerName = 'Unknown Farmer';
      });
    }
  }

  void _loadFarmerCount() async {
    final data = widget.data.data() as Map<String, dynamic>;
    final productName = data['name'] ?? '';

    if (productName.isNotEmpty) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: productName)
            .get();

        setState(() {
          farmerCount = snapshot.docs.length;
        });
      } catch (e) {
        print('Error loading farmer count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data.data() as Map<String, dynamic>;

    // Safely get the data from Firestore, providing default values to prevent errors.
    final String name = data['name'] ?? 'No Name Available';
    final String imageUrl = data['imageUrl'] ?? ''; // Default to empty string
    final double price = data['price'] ?? 0;
    final dynamic categoryData = data['category'] ?? 'Uncategorized';

    String category;

    if (categoryData is List && categoryData.isNotEmpty) {
      // If it's a list, take the first element
      category = categoryData.first.toString();
    } else if (categoryData is String) {
      // If it's a string, use it directly
      category = categoryData;
    } else {
      // Fallback in case it's something else
      category = 'Uncategorized';
    }
    final dynamic unitTypeData = data['unit'] ?? 'unit';

    String unitType;

    if (unitTypeData is List && unitTypeData.isNotEmpty) {
      // If it's a list, take the first element
      unitType = unitTypeData.first.toString();
    } else if (unitTypeData is String) {
      // If it's a string, use it directly
      unitType = unitTypeData;
    } else {
      // Fallback in case it's something else
      unitType = 'Uncategorized';
    }

    // Format the price safely
    final formatter = NumberFormat('#,###');
    final displayNumber = formatter.format(price);

    return Container(
      width: 200,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Multiple Farmers Indicator
          if (farmerCount > 1)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group, size: 14, color: Colors.orange.shade700),
                  SizedBox(width: 4),
                  Text(
                    '$farmerCount farmers sell this',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported_outlined),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade300,
                                  child: Container(
                                    color: Colors.grey,
                                    width: double.infinity,
                                  ),
                                );
                              }
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4),

                      // Farmer Name
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          farmerName,
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

                      // Category
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: 8),

                      // Price and Compare Button
                      Row(
                        children: [
                          data['stock'] > 0
                              ? Text(
                                  "\$$displayNumber",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade600,
                                  ),
                                )
                              : Text(
                                  "Out of Stock",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                          Text(
                            "/$unitType",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),

                          // Compare/View All Button
                          if (farmerCount > 1)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FarmersSellingProductScreen(
                                          productName: name,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.compare_arrows,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
