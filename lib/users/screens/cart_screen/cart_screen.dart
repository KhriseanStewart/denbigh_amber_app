import 'package:denbigh_app/widgets/custom_btn.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> cartItems = [
    {
      'image':
          "https://agrilinkages.gov.jm/storage/product/649/image/Screenshot_20250611_123227_Google_1749664701.jpg",
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 0,
      'farmerName': ' John',
    },
    {
      //'image': 'assets/banana.webp',
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 0,
      'farmerName': 'winston',
    },
    {
      'image':
          "https://agrilinkages.gov.jm/storage/product/649/image/Screenshot_20250611_123227_Google_1749664701.jpg",
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 0,
      'farmerName': 'jones',
    },
    {
      'image':
          "https://agrilinkages.gov.jm/storage/product/649/image/Screenshot_20250611_123227_Google_1749664701.jpg",
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 0,
      'farmerName': 'jones janebuebuyhb',
    },
  ];
  //commented no use for loading as yet, changed asset to network so it will load automatically
  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(const Duration(seconds: 2), () {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // this logic is to be change to suit the cart items from the database
    double itemCost = cartItems.fold(
      0.0,
      (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as num)),
    );
    double subTax = itemCost * 0.08;
    double deliveryFee =
        10.0; // This can be dynamic based on location or other factors

    double totalCost = itemCost + subTax + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.white,
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: hexToColor("F4F6F8"),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Item Cost: \$${itemCost.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  "Sub-Tax: \$${subTax.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delivery Fee: \$${deliveryFee.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      itemCost == 0
                          ? ""
                          : "Total: \$${totalCost.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Center(
                  child: CustomButton(
                    btntext: "Continue to Checkout",
                    onpress: () {
                      displaySnackBar(context, "Checkout soon");
                    },
                    isBoldtext: true,
                    bgcolor: Colors.grey.shade300,
                    textcolor: Colors.black,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: (item['image'] != null
                                ? Image.network(
                                    item['image'],
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress != null) {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                width: 150,
                                                height: 150,
                                                color: Colors.grey.shade300,
                                              ),
                                            );
                                          } else {
                                            return child;
                                          }
                                        },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey.shade200,
                                              width: 150,
                                              height: 150,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    width: 150,
                                    height: 150,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  )),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  item['category'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xff828282),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "\$${item['price'].toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "/${item['unit']}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Farmer: ${item['farmerName']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              //logic to remove the item from the cart to add here
                            },
                          ),
                          SizedBox(height: 30),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffF5F5F5),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    color: item['quantity'] == 0
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                  onPressed: item['quantity'] == 0
                                      ? null
                                      : () {
                                          setState(() {
                                            cartItems[index]['quantity']--;
                                          });
                                        },
                                ),
                                // Show quantity only if quantity >= 1
                                if (item['quantity'] >= 1)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      '${item['quantity']}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      cartItems[index]['quantity']++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
