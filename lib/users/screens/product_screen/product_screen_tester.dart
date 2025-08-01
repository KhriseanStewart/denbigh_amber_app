import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/screens/farmers_info_for_user.dart';
import 'package:denbigh_app/users/database/cart.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:denbigh_app/widgets/ExpandedText.dart';
import 'package:denbigh_app/widgets/custom_btn.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class ProductScreenTester extends StatefulWidget {
  const ProductScreenTester({super.key});

  @override
  State<ProductScreenTester> createState() => _ProductScreenTesterState();
}

class _ProductScreenTesterState extends State<ProductScreenTester> {
  int quantity = 0;
  bool isLoading = false;
  bool exists = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null) {
      return;
    }

    final args = arguments as QueryDocumentSnapshot;
    if (quantity == 0) {
      setState(() {
        try {
          final data = args;
          quantity = data?['minUnitNum'] ?? 1;
        } catch (e) {
          quantity = 1;
        }
      });
    }
    checkProductInCart();
  }

  void checkProductInCart() async {
    try {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments == null) return;

      final args = arguments as QueryDocumentSnapshot;
      final data = args.data() as Map<String, dynamic>?;
      final productId = data?['productId'];

      if (productId != null && auth?.uid != null) {
        bool inCart = await Cart_Service().isProductInCart(
          auth!.uid,
          productId,
        );
        if (mounted) {
          setState(() {
            exists = inCart;
          });
        }
      }
    } catch (e) {
      print('Error checking product in cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('No product data available'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final args = arguments as QueryDocumentSnapshot;

    try {
      final data = args.data() as Map<String, dynamic>?;
      final num priceNum = data?['price'] ?? 0;
      final int totalNum = priceNum.toInt();
      final formatter = NumberFormat('#,###');
      final firebasePrice = formatter.format(totalNum);

      int quantityPriceDemo = (priceNum * quantity).toInt();
      final quantityPriceNum = quantityPriceDemo;
      final quantityPrice = formatter.format(quantityPriceNum);

      final dynamic categoryData = data?['category'] ?? 'Uncategorized';

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

      final dynamic unitTypeData = data?['unit'] ?? 'unit';

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

      void handleAddToCart() async {
        try {
          setState(() {
            isLoading = true;
          });
          await Cart_Service().addToCart(auth!.uid, args, quantity);
          exists = await Cart_Service().isProductInCart(
            auth!.uid,
            args['productId'],
          );
          showCenteredBottomSheet(context);
          // Show the Lottie popup after successful add to cart
          await Future.delayed(Duration(seconds: 3), () {
            Navigator.pop(context);
          });
          setState(() {
            // Animation state removed - not needed
          });

          setState(() {
            isLoading = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to add to cart')));
        } finally {
          setState(() {
            isLoading = false;
          });
        }
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
                            data?['imageUrl']?.toString() ?? '',
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
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            icon: Icon(
                              Icons.close,
                              size: 30,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: isLoading
                                  ? Colors.grey
                                  : Colors.lightGreen,
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
                                    data?['name']?.toString() ??
                                        'Unknown Product',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Switzer',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Farmer name
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('farmersData')
                                        .doc(data?['farmerId'] ?? '')
                                        .get(),
                                    builder: (context, farmerSnapshot) {
                                      String farmerName = 'Loading...';
                                      if (farmerSnapshot.hasData &&
                                          farmerSnapshot.data!.exists) {
                                        final farmersData =
                                            farmerSnapshot.data!.data()
                                                as Map<String, dynamic>?;
                                        farmerName =
                                            farmersData?['farmerName'] ??
                                            farmersData?['name'] ??
                                            farmersData?['firstName'] ??
                                            'Unknown Farmer';
                                      } else if (farmerSnapshot.hasError) {
                                        farmerName = 'Unknown Farmer';
                                      }

                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 14,
                                              color: Colors.green.shade700,
                                            ),
                                            SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () {
                                                FarmerInfoPopup.showFarmerInfo(
                                                  context,
                                                  data?['farmerId'] ?? '',
                                                );
                                              },
                                              child: Text(
                                                'By: $farmerName',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w500,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
                            color: Colors.lightGreen,
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
                                        data?['location'] ?? 'Unknown Location',
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
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                          ),
                          child: ExpandableText(
                            text:
                                data?['description'] ??
                                'No description available',
                          ),
                        ),

                        SizedBox(height: 24),

                        // Other farmers selling this product section
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10.0,
                  ),
                  child: args['stock'] > 0
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            exists
                                ? CustomButtonElevated(
                                    icon: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 24,
                                      color: Colors.black,
                                    ),
                                    btntext: "Item in Cart",
                                    bgcolor: Colors.lightGreen,
                                    textcolor: Colors.black,
                                    isBoldtext: false,
                                    size: 18,
                                  )
                                : CustomButtonElevated(
                                    btntext: isLoading
                                        ? 'Adding..'
                                        : "Add to Cart",
                                    // Inside your _ProductScreenState class
                                    onpress: isLoading ? null : handleAddToCart,
                                    bgcolor: isLoading
                                        ? Colors.grey
                                        : Colors.lightGreen,
                                    textcolor: Colors.white,
                                    isBoldtext: true,
                                    size: 18,
                                  ),
                          ],
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButtonElevated(
                              icon: Icon(
                                Icons.error,
                                size: 24,
                                color: Colors.white,
                              ),
                              btntext: "Out of Stock",
                              onpress: () {
                                showAlertDialog(context);
                              },
                              bgcolor: Colors.redAccent,
                              textcolor: Colors.white,
                              isBoldtext: false,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading product data'),
              Text('$e', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Item out of Stock"),
          content: Text("Try again later"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  void showCenteredBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          // Optional: add some padding or decoration
          padding: EdgeInsets.all(16),
          // Center the content
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content height
              children: [
                Lottie.asset(
                  "assets/AddToCartSuccess.json",
                  width: 200,
                  height: 200,
                  repeat: false,
                ),
                SizedBox(height: 16),
                Text('Item added to cart!', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}
