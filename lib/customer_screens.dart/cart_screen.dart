import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Add this for shimmer loading simulation
  bool _isLoading = true;
  int quantity = 0; // this is the quantity of the product to be added to the cart

  // this list is a simulated list add cart from firebase
  final List<Map<String, dynamic>> cartItems = [
    {
      'image': 'assets/banana.webp',
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 1,
      'farmerName': ' John',
    },
    {
      //'image': 'assets/banana.webp',
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 1,
      'farmerName': 'winston',
    },
    {
      'image': 'assets/banana.webp',
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 1,
      'farmerName': 'jones',
    },
    {
      'image': 'assets/banana.webp',
      'name': 'banana',
      'category': 'Legumes',
      'price': 120.00,
      'unit': 'per hand',
      'quantity': 1,
      'farmerName': 'jones janebuebuyhb',
    },

  ];

  @override
  void initState() {
    super.initState();
    // Simulate loading for 2 seconds, then show images
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

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
        automaticallyImplyLeading: true,
       
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
                //logic to show the total cost, sub-tax, and delivery fee
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
                            child: _isLoading
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      color: Colors.grey.shade300,
                                    ),
                                  )
                                : (item['image'] != null
                                    ? Image.asset(
                                        item['image'],
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey.shade200,
                                          width: 150,
                                          height: 150,
                                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        width: 150,
                                        height: 150,
                                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                      )),
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
                              // Quantity selector
                              //the logic to show the unit of the product to be added
                              SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Farmer: ${item['farmerName']}'),
                                   
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Delete button
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
                          color: quantity == 0 ? Colors.grey : Colors.black,
                        ),
                        onPressed:
                            quantity == 0
                                ? null
                                : () {
                                  setState(() {
                                    quantity--;
                                  });
                                },
                      ),
                      // Show quantity only if quantity >= 1
                      if (quantity >= 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '$quantity',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      // Plus button
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
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