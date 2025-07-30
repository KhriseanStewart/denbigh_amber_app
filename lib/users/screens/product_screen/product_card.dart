import 'package:cloud_firestore/cloud_firestore.dart';
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
    try {
      final data = widget.data.data() as Map<String, dynamic>?;
      final farmerId = data?['farmerId'];

      if (farmerId != null && mounted) {
        final farmerDoc = await FirebaseFirestore.instance
            .collection('farmersData')
            .doc(farmerId)
            .get();

        if (farmerDoc.exists && mounted) {
          final farmerData = farmerDoc.data();
          setState(() {
            farmerName =
                farmerData?['name']?.toString() ??
                farmerData?['firstName']?.toString() ??
                farmerData?['farmerName']?.toString() ??
                'Unknown Farmer';
          });
        } else if (mounted) {
          setState(() {
            farmerName = 'Unknown Farmer';
          });
        }
      } else if (mounted) {
        setState(() {
          farmerName = 'Unknown Farmer';
        });
      }
    } catch (e) {
      print('Error loading farmer info: $e');
      if (mounted) {
        setState(() {
          farmerName = 'Unknown Farmer';
        });
      }
    }
  }

  void _loadFarmerCount() async {
    try {
      final data = widget.data.data() as Map<String, dynamic>?;
      final productName = data?['name']?.toString() ?? '';

      if (productName.isNotEmpty && mounted) {
        final snapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: productName)
            .get();

        if (mounted) {
          setState(() {
            farmerCount = snapshot.docs.length;
          });
        }
      }
    } catch (e) {
      print('Error loading farmer count: $e');
      if (mounted) {
        setState(() {
          farmerCount = 1; // Default fallback
        });
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final data = widget.data.data() as Map<String, dynamic>?;

      // Add null check for data
      if (data == null) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text('No data available')),
        );
      }

      // Safely get the data from Firestore, providing default values to prevent errors.
      final String name = data['name']?.toString() ?? 'No Name Available';
      final String imageUrl =
          data['imageUrl']?.toString() ?? ''; // Default to empty string
      final num priceNum = data['price'] ?? 0;
      final double price = priceNum.toDouble();
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
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                        // Product Name - Limited to middle width with clean styling
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 8),

                        // Farmer Name and Category Row
                        Row(
                          children: [
                            // Farmer Name (Left side)
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 12,
                                      color: Colors.green.shade700,
                                    ),
                                    SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        farmerName,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 6),

                            // Category (Right side)
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        // Price/Unit and Location Row
                        Row(
                          children: [
                            // Price/Unit (Left side)
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child:
                                          (data['stock'] != null &&
                                              data['stock'] > 0)
                                          ? Text(
                                              "\$$displayNumber",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(
                                              "Out of Stock",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                    if (data['stock'] != null &&
                                        data['stock'] > 0)
                                      Flexible(
                                        child: Text(
                                          "/$unitType",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 6),

                            // Location (Right side)
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 10,
                                      color: Colors.grey.shade700,
                                    ),
                                    SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        data['location'] ?? 'No location',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
    } catch (e) {
      // Return a fallback widget if there's any error
      print('Error in UserProductCard build: $e');
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Error loading product',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }
}
