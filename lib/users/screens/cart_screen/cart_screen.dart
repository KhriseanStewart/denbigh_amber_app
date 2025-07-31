import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/cart.dart';
import 'package:denbigh_app/users/screens/orders/user_orders_screen.dart';
import 'package:denbigh_app/widgets/custom_btn.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, TextEditingController> controllers = {};
  Map<String, int> cartQuantities = {};
  bool _isProcessingOrder = false;
  double totalCost = 0;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    // Dispose all controllers
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void handleCheckout() async {
    Navigator.pushNamed(
      context,
      AppRouter.card,
      arguments: <String, dynamic>{'totalCost': totalCost},
    );
  }

  Future<void> _updateCartItemQuantity(
    String cartItemId,
    int newQuantity,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cartItems')
          .doc(cartItemId)
          .update({'customerQuantity': newQuantity});
    } catch (e) {
      // Show error to user
      displaySnackBar(context, "Failed to update quantity. Please try again.");
    }
  }

  // Helper to initialize controllers
  void initializeControllers(List<QueryDocumentSnapshot> cartItems) {
    for (var item in cartItems) {
      final id = item.id;
      if (!controllers.containsKey(id)) {
        final data = item.data() as Map<String, dynamic>?;
        final currentQty =
            (cartQuantities[id] ?? data?['customerQuantity'] ?? 1).toString();
        controllers[id] = TextEditingController(text: currentQty);
      }
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
            return Center(
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FeatherIcons.shoppingCart,
                    size: 100,
                    color: Colors.grey,
                  ),
                  Text("Your cart is empty"),
                  CustomButtonElevated(
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    btntext: "View My Orders",
                    textcolor: Colors.white,
                    bgcolor: Colors.lightGreen,
                    onpress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserOrdersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;
          initializeControllers(cartItems);

          int itemCost = 0;
          for (var item in cartItems) {
            final id = item.id;
            final data = item.data() as Map<String, dynamic>?;
            final quantity =
                cartQuantities[id] ?? data?['customerQuantity'] ?? 1;
            itemCost += ((data?['price'] as num? ?? 0) * quantity).toInt();
          }

          int subTax = (itemCost * 0.08).toInt();
          double deliveryFee = 10;
          totalCost = itemCost + subTax + deliveryFee;
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
                        onpress: _isProcessingOrder ? null : handleCheckout,
                        isBoldtext: true,
                        bgcolor: _isProcessingOrder
                            ? Colors.grey
                            : Colors.lightGreen,
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
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: Text("No data found"));
                    }
                    final cartItems = snapshot.data!.docs;

                    // Initialize cart quantities
                    for (var doc in cartItems) {
                      if (!cartQuantities.containsKey(doc.id)) {
                        try {
                          final data = doc.data() as Map<String, dynamic>?;
                          cartQuantities[doc.id] =
                              data?['customerQuantity'] ?? 1;
                        } catch (e) {
                          cartQuantities[doc.id] = 1;
                        }
                      }
                    }

                    // Group items by farmerId
                    Map<String, List<QueryDocumentSnapshot>> itemsByFarmer = {};
                    for (var item in cartItems) {
                      final data = item.data() as Map<String, dynamic>?;
                      final farmerId = data?['farmerId'] ?? 'unknown';

                      if (!itemsByFarmer.containsKey(farmerId)) {
                        itemsByFarmer[farmerId] = [];
                      }
                      itemsByFarmer[farmerId]!.add(item);
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      itemCount: itemsByFarmer.keys.length,
                      itemBuilder: (context, index) {
                        final farmerId = itemsByFarmer.keys.elementAt(index);
                        final farmerItems = itemsByFarmer[farmerId]!;

                        return buildFarmerSection(farmerId, farmerItems);
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
    try {
      String farmerName = 'Loading...';
      // Safely access item data with null checks
      final data = item.data() as Map<String, dynamic>?;
      if (data == null) {
        return SizedBox.shrink();
      }

      final price = (data['price'] as num? ?? 0).toInt();
      final customerQuantity = data['customerQuantity'] ?? 1;
      final totalPrice = price * customerQuantity;

      final id = item.id;
      final currentQuantity = cartQuantities[id] ?? customerQuantity;
      final dynamic categoryData = data['category'] ?? 'Uncategorized';
      final controller = controllers[id]!;

      String category;

      // Ensure controller text is always current
      if (controller.text != currentQuantity.toString()) {
        controller.text = currentQuantity.toString();
      }

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
      final dynamic unitTypeData = data['unitType'] ?? 'unit';

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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: (data['imageUrl'] != null
                          ? Image.network(
                              data['imageUrl'],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                              errorBuilder: (context, error, stackTrace) =>
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
                          data['name'] ?? 'Unknown Product',
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
                            category,
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
                              "\$$totalPrice",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "/$unitType",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('farmersData')
                                    .doc(data['farmerId'])
                                    .get(),
                                builder: (context, farmerSnapshot) {
                                  if (farmerSnapshot.hasData &&
                                      farmerSnapshot.data!.exists) {}

                                  if (farmerSnapshot.hasData &&
                                      farmerSnapshot.data!.exists) {
                                    final farmersData =
                                        farmerSnapshot.data!.data()
                                            as Map<String, dynamic>?;

                                    // Safely get farmer name with type checking
                                    final farmerNameField =
                                        farmersData?['farmerName'];
                                    final nameField = farmersData?['name'];
                                    final firstNameField =
                                        farmersData?['firstName'];

                                    if (farmerNameField != null &&
                                        farmerNameField is String) {
                                      farmerName = farmerNameField;
                                    } else if (nameField != null &&
                                        nameField is String) {
                                    } else if (firstNameField != null &&
                                        firstNameField is String) {
                                      farmerName = firstNameField;
                                    }
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
                                      'By: $farmerName',
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
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black54),
                  onPressed: () {
                    //logic to remove the item from the cart to add here
                    Cart_Service().removeFromCart(userId, data['productId']);
                  },
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: (data['quantity'] ?? 0) < 0
                        ? Colors.red
                        : Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: (data['quantity'] ?? 0) == 0
                              ? Colors.grey
                              : Colors.black,
                        ),
                        onPressed: (data['quantity'] ?? 0) == 0
                            ? null
                            : () async {
                                if (currentQuantity >
                                    (data['minUnitNum'] ?? 1)) {
                                  final newQuantity = currentQuantity - 1;
                                  setState(() {
                                    cartQuantities[id] = newQuantity;
                                  });
                                  // Update Firestore
                                  await _updateCartItemQuantity(
                                    id,
                                    newQuantity,
                                  );
                                } else {
                                  displaySnackBar(
                                    context,
                                    "Cannot go below minimum unit number (${data["minUnitNum"] ?? 1})",
                                  );
                                }
                              },
                      ),
                      // Show quantity only if quantity >= 1
                      if ((data['quantity'] ?? 0) >= 1)
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                            onSubmitted: (value) async {
                              final int? newQty = int.tryParse(value);
                              if (newQty != null) {
                                setState(() {
                                  cartQuantities[id] = newQty;
                                });
                                await _updateCartItemQuantity(id, newQty);
                              } else {
                                // Optional: Reset to last known quantity if input invalid
                                controller.text =
                                    cartQuantities[id]?.toString() ??
                                    data['customerQuantity'].toString();
                              }
                            },
                          ),
                        ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          final newQuantity = currentQuantity + 1;
                          setState(() {
                            cartQuantities[id] = newQuantity;
                          });
                          // Update Firestore
                          await _updateCartItemQuantity(id, newQuantity);
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
    } catch (e) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text('Error loading item', style: TextStyle(color: Colors.red)),
      );
    }
  }

  // New method to build farmer section with header
  Widget buildFarmerSection(
    String farmerId,
    List<QueryDocumentSnapshot> farmerItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Farmer header
        FutureBuilder<String>(
          future: _getFarmerName(farmerId),
          builder: (context, snapshot) {
            final farmerName = snapshot.data ?? 'Loading...';
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.store, color: Colors.green.shade700, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'From: $farmerName',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${farmerItems.length} items',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Farmer's products
        ...farmerItems.map((item) => buildProductCard(item)),
        SizedBox(height: 16), // Space between farmers
      ],
    );
  }

  // Helper method to get farmer name
  Future<String> _getFarmerName(String farmerId) async {
    try {
      final farmerDoc = await FirebaseFirestore.instance
          .collection('farmersData')
          .doc(farmerId)
          .get();

      if (farmerDoc.exists) {
        final farmersData = farmerDoc.data();
        return farmersData?['farmerName'] ??
            farmersData?['name'] ??
            farmersData?['firstName'] ??
            'Unknown Farmer';
      }
      return 'Unknown Farmer';
    } catch (e) {
      return 'Unknown Farmer';
    }
  }
}
