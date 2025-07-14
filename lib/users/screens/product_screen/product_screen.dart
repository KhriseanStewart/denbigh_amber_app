import 'package:cloud_firestore/cloud_firestore.dart';
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

    final totalNum = args['price']; // Example fetched data
    final formatter = NumberFormat('#,###'); //single formatter for both
    final firebasePrice = formatter.format(totalNum);

    int quantityPriceDemo = args['price'] * quantity;
    final quantityPriceNum = quantityPriceDemo;
    final quantityPrice = formatter.format(quantityPriceNum);

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
                            args['category'],
                            style: TextStyle(
                              fontFamily: 'OleoScript',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
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
                                    fontSize: 34,
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
                                          fontSize: 20,
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
                                        " /${args['unitType']}",
                                        style: TextStyle(
                                          fontSize: 16,
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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
                                    Text("$quantity"),
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
                              SizedBox(height: 4),
                              Text(
                                "\$$quantityPrice",
                                style: TextStyle(
                                  fontSize: 20,
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
                                    fontSize: 20,
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
                                        fontSize: 16,
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
                                        fontSize: 16,
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
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(color: Colors.grey.shade300),
                        child: ExpandableText(text: args['description']),
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
                  onpress: () {},
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
