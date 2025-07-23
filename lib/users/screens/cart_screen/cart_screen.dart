import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/database/cart.dart';
import 'package:denbigh_app/users/database/order_service.dart';
import 'package:denbigh_app/widgets/custom_btn.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, int> cartQuantities = {};
  bool _isProcessingOrder = false;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  /// Handle checkout process
  Future<void> _handleCheckout() async {
    if (_isProcessingOrder) return;

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      final success = await OrderService().createOrderFromCart(userId);

      if (success) {
        displaySnackBar(context, "Order placed successfully!");
        // Optionally navigate to order confirmation screen
        // Navigator.pushNamed(context, AppRouter.orderConfirmation);
      } else {
        displaySnackBar(context, "Failed to place order. Please try again.");
      }
    } catch (e) {
      displaySnackBar(context, "Error: ${e.toString()}");
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // this logic is to be change to suit the cart items from the database

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
      body: StreamBuilder(
        stream: Cart_Service().readCart(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Your cart is empty"));
          }

          final cartItems = snapshot.data!.docs;

          double itemCost = 0;
          for (var item in cartItems) {
            final quantity =
                cartQuantities[item.id] ?? item['customerQuantity'];
            itemCost += item['price'] * quantity;
          }

          double subTax = itemCost * 0.08;
          double deliveryFee = 10.0;
          double totalCost = itemCost + subTax + deliveryFee;
          return Column(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                      child: CustomButtonElevated(
                        btntext: _isProcessingOrder
                            ? "Processing..."
                            : "Continue to Checkout",
                        onpress: _isProcessingOrder ? null : _handleCheckout,
                        isBoldtext: true,
                        bgcolor: _isProcessingOrder
                            ? Colors.grey
                            : Colors.green,
                        textcolor: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: Cart_Service().readCart(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return Center(child: Text("No data found"));
                    }
                    final cartItem = snapshot.data!.docs;
                    for (var doc in cartItem) {
                      if (!cartQuantities.containsKey(doc.id)) {
                        cartQuantities[doc.id] = doc['customerQuantity'];
                      }
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      itemCount: cartItem.length,
                      itemBuilder: (context, index) {
                        final item = cartItem[index];
                        return buildProductCard(item);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildProductCard(QueryDocumentSnapshot<Object?> item) {
    final totalPrice = item['price'] * item['customerQuantity'];
    //int finalQuantity = item['customerQuantity'];
    final id = item.id;
    final currentQuantity = cartQuantities[id] ?? item['customerQuantity'];
    //final totalPriceTwo = item['price'] * currentQuantity;
    final dynamic categoryData = item['category'] ?? 'Uncategorized';

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
    final dynamic unitTypeData = item['unitType'] ?? 'unit';

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
                child: (item['imageUrl'] != null
                    ? Image.network(
                        item['imageUrl'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress != null) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
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
                        errorBuilder: (context, error, stackTrace) => Container(
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(fontSize: 11, color: Color(0xff828282)),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "\$$totalPrice",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "/$unitType",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('farmers')
                              .doc(item['farmerId'])
                              .get(),
                          builder: (context, farmerSnapshot) {
                            String farmerName = 'Unknown Farmer';
                            if (farmerSnapshot.hasData &&
                                farmerSnapshot.data!.exists) {
                              final farmerData =
                                  farmerSnapshot.data!.data()
                                      as Map<String, dynamic>?;
                              farmerName =
                                  farmerData?['name'] ??
                                  farmerData?['firstName'] ??
                                  farmerData?['farmerName'] ??
                                  'Unknown Farmer';
                            }

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
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
                icon: const Icon(Icons.delete_outline, color: Colors.black54),
                onPressed: () {
                  //logic to remove the item from the cart to add here
                  Cart_Service().removeFromCart(userId, item['productId']);
                },
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: item['quantity'] < 0 ? Colors.red : Color(0xffF5F5F5),
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
                              print(currentQuantity);
                              setState(() {
                                if (currentQuantity > item['minUnitNum']) {
                                  cartQuantities[id] = currentQuantity - 1;
                                } else {
                                  displaySnackBar(
                                    context,
                                    "Cannot go below minimum unit number (${item["minUnitNum"]})",
                                  );
                                }
                              });
                            },
                    ),
                    // Show quantity only if quantity >= 1
                    if (item['quantity'] >= 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '$currentQuantity',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        print(currentQuantity);
                        setState(() {
                          cartQuantities[id] = currentQuantity + 1;
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
  }
}
