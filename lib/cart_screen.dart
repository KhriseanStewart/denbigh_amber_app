import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // this list is a simulated list add cart from firebase
  final List<Map<String, dynamic>> cartItems = [
    {
      'image': 'assets/banna.webp',
      'name': 'banna',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 1,
      'farmerName': ' John',
    },
    {
      //'image': 'assets/banna.webp',
      'name': 'banna',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 1,
      'farmerName': 'winston',
    },
    {
      'image': 'assets/banna.webp',
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 1,
      'farmerName': 'jones',
    },

  ];

  @override
  Widget build(BuildContext context) {
    // Example calculations
    double totalCost = cartItems.fold(
      0.0,
      (sum, item) => sum + item['price'] * item['quantity'],
    );
    double subTax = totalCost * 0.08; // Example sub-tax
    double deliveryFee = 10.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.grey,
      ),
      backgroundColor: Color(0xffF9F9F9),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20) ),
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
                Text("Total Cost:", style: TextStyle(fontSize: 15)),
                SizedBox(height: 6),
                Text("Sub-Tax:", style: TextStyle(fontSize: 15)),
                SizedBox(height: 6),
                Text("Delivery Fee:", style: TextStyle(fontSize: 15)),
                SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      // add the logic to continue to checkout with the arguments
                    },
                    child:  Text("Continue to Checkout"),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Cart items list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  margin:  EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image goes here
                      Container(
                        width: 150,
                        height: 150,
                        child: AspectRatio(
                          aspectRatio: 4,
                        
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: item['image'] != null
                                ? Image.asset(
                                    item['image'],
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.image_not_supported, size: 50, color: Colors.grey)
                          ),
                        ),
                      ),
                     SizedBox(width: 12),
                      // Product Info goes here
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style:  TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                               SizedBox(height: 8),
                              Container(
                                padding:  EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:  Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  item['category'],
                                  style:  TextStyle(
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
                                    style:  TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  
                                  Text(
                                    "/${item['unit']}",
                                    style:  TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                               SizedBox(height: 6),
                              // Quantity selector
                              //the logic to show the unit of the product to be added
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Farmer: ${item['farmerName']}'),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:  Color(0xffF5F5F5),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon:  Icon(
                                            Icons.remove,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            // decrease quantity logic should go here
                                          },
                                        ),
                                        Text(
                                          "${item['quantity']}",
                                          style:  TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon:  Icon(Icons.add, size: 18),
                                          onPressed: () {
                                            // increase quantity logic should go here
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          //logic to remove the item from the cart to add here
                        },
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
