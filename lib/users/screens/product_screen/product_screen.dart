import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/database/cart.dart';
import 'package:denbigh_app/users/database/multi_farmer_product_service.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:denbigh_app/users/screens/products/farmers_selling_product_screen.dart';
import 'package:denbigh_app/widgets/ExpandedText.dart';
import 'package:denbigh_app/widgets/custom_btn.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as QueryDocumentSnapshot;
    if (quantity == 0) {
      setState(() {
        quantity = args['minUnitNum'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as QueryDocumentSnapshot;

    final double totalNum = args['price']; // Example fetched data
    final formatter = NumberFormat('#,###'); //single formatter for both
    final firebasePrice = formatter.format(totalNum);

    int quantityPriceDemo = (args['price'] * quantity).toInt();
    final quantityPriceNum = quantityPriceDemo;
    final quantityPrice = formatter.format(quantityPriceNum);

    final dynamic categoryData = args['category'] ?? 'Uncategorized';

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

    final dynamic unitTypeData = args['unit'] ?? 'unit';

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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 340,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.network(
                          args['imageUrl'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade400,
                                highlightColor: Colors.grey.shade200,
                                child: Container(color: Colors.grey),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported_outlined,
                              size: 90,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            size: 30,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite,
                            size: 30,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          style: IconButton.styleFrom(),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 4.0,
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontFamily: 'OleoScript',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Wrap text in Flexible to prevent overflow
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product name with ellipsis
                                Text(
                                  args['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Switzer',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Price row
                                Row(
                                  children: [
                                    // Wrap price text in Flexible
                                    Flexible(
                                      child: Text(
                                        "\$$firebasePrice",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Switzer',
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    // Wrap unit text in Flexible
                                    Flexible(
                                      child: Text(
                                        " /$unitType",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Switzer',
                                          fontWeight: FontWeight.w300,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Quantity selector and label
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        print(quantity);
                                        setState(() {
                                          quantity--;
                                        });
                                      },
                                      icon: Icon(Icons.remove),
                                    ),
                                    args["stock"] < 0
                                        ? Text("Out of Stock")
                                        : Text("$quantity"),
                                    IconButton(
                                      onPressed: () {
                                        print(quantity);
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                      icon: Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "\$$quantityPrice",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Switzer',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Divider(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Column(
                              spacing: 2,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Meet-up Preferences",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Switzer',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      args['location'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      FeatherIcons.truck,
                                      color: Colors.white,
                                    ),
                                    //TODO: make sure this is an optional to see
                                    Text(
                                      "Delivery Available",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Description",
                        style: TextStyle(
                          fontFamily: 'Switzer',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(color: Colors.grey.shade300),
                        child: ExpandableText(text: args['description']),
                      ),

                      SizedBox(height: 24),

                      // Other farmers selling this product section
                      StreamBuilder<List<QueryDocumentSnapshot>>(
                        stream: MultiFarmerProductService()
                            .getFarmersSellingProduct(args['name']),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.length <= 1) {
                            return SizedBox.shrink(); // Don't show if only one farmer
                          }

                          final otherFarmers = snapshot.data!
                              .where((doc) => doc.id != args.id)
                              .toList();

                          if (otherFarmers.isEmpty) {
                            return SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Other farmers selling this",
                                    style: TextStyle(
                                      fontFamily: 'Switzer',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FarmersSellingProductScreen(
                                                productName: args['name'],
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: otherFarmers.length > 3
                                      ? 3
                                      : otherFarmers.length,
                                  itemBuilder: (context, index) {
                                    final farmerProduct = otherFarmers[index];
                                    return Container(
                                      width: 200,
                                      margin: EdgeInsets.only(right: 12),
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Farmer name
                                          FutureBuilder<DocumentSnapshot>(
                                            future: FirebaseFirestore.instance
                                                .collection('farmers')
                                                .doc(farmerProduct['farmerId'])
                                                .get(),
                                            builder: (context, farmerSnapshot) {
                                              String farmerName =
                                                  'Unknown Farmer';
                                              if (farmerSnapshot.hasData &&
                                                  farmerSnapshot.data!.exists) {
                                                final farmerData =
                                                    farmerSnapshot.data!.data()
                                                        as Map<
                                                          String,
                                                          dynamic
                                                        >?;
                                                farmerName =
                                                    farmerData?['name'] ??
                                                    farmerData?['firstName'] ??
                                                    'Unknown Farmer';
                                              }

                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  farmerName,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.green.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(height: 8),

                                          // Price comparison
                                          Row(
                                            children: [
                                              Text(
                                                '\$${NumberFormat('#,###').format(farmerProduct['price'])}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      farmerProduct['price'] <
                                                          args['price']
                                                      ? Colors.green.shade600
                                                      : farmerProduct['price'] >
                                                            args['price']
                                                      ? Colors.red.shade600
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              if (farmerProduct['price'] <
                                                  args['price'])
                                                Icon(
                                                  Icons.trending_down,
                                                  color: Colors.green,
                                                  size: 16,
                                                )
                                              else if (farmerProduct['price'] >
                                                  args['price'])
                                                Icon(
                                                  Icons.trending_up,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                            ],
                                          ),

                                          Spacer(),

                                          // View button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 28,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductScreen(),
                                                    settings: RouteSettings(
                                                      arguments: farmerProduct,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.green.shade100,
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                'View',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomButtonElevated(
                  btntext: "Add to Cart",
                  onpress: () {
                    Cart_Service().addToCart(auth!.uid, args, quantity);
                  },
                  bgcolor: Colors.grey.shade400,
                  textcolor: Colors.black,
                  isBoldtext: true,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
