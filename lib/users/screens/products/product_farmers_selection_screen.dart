import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/database/cart.dart';
import 'package:denbigh_app/users/database/multi_farmer_product_service.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductFarmersSelectionScreen extends StatefulWidget {
  final String productName;

  const ProductFarmersSelectionScreen({super.key, required this.productName});

  @override
  State<ProductFarmersSelectionScreen> createState() =>
      _ProductFarmersSelectionScreenState();
}

class _ProductFarmersSelectionScreenState
    extends State<ProductFarmersSelectionScreen> {
  Map<String, int> quantities = {}; // farmerId -> quantity
  Map<String, QueryDocumentSnapshot> selectedProducts =
      {}; // farmerId -> product

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.productName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: MultiFarmerProductService().getFarmersSellingProduct(
          widget.productName,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No farmers selling "${widget.productName}" found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final farmerId = product['farmerId'] ?? '';

              return FarmerProductSelectionCard(
                product: product,
                quantity: quantities[farmerId] ?? 0,
                onQuantityChanged: (newQuantity) {
                  setState(() {
                    if (newQuantity > 0) {
                      quantities[farmerId] = newQuantity;
                      selectedProducts[farmerId] = product;
                    } else {
                      quantities.remove(farmerId);
                      selectedProducts.remove(farmerId);
                    }
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (selectedProducts.isEmpty) return null;

    int totalItems = quantities.values.fold(0, (sum, qty) => sum + qty);
    double totalPrice = 0;

    selectedProducts.forEach((farmerId, product) {
      final price = (product['price'] ?? 0).toDouble();
      final quantity = quantities[farmerId] ?? 0;
      totalPrice += price * quantity;
    });

    final formatter = NumberFormat('#,###');
    final formattedTotal = formatter.format(totalPrice);

    return FloatingActionButton.extended(
      onPressed: _addToCart,
      backgroundColor: Colors.green,
      icon: Icon(Icons.shopping_cart, color: Colors.white),
      label: Text(
        'Add $totalItems items - \$$formattedTotal',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _addToCart() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to add items to cart'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cartService = Cart_Service();

      for (String farmerId in selectedProducts.keys) {
        final product = selectedProducts[farmerId]!;
        final quantity = quantities[farmerId]!;

        await cartService.addToCart(currentUser.uid, product, quantity);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Items added to cart successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear selections after adding to cart
      setState(() {
        quantities.clear();
        selectedProducts.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding items to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class FarmerProductSelectionCard extends StatefulWidget {
  final QueryDocumentSnapshot product;
  final int quantity;
  final Function(int) onQuantityChanged;

  const FarmerProductSelectionCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<FarmerProductSelectionCard> createState() =>
      _FarmerProductSelectionCardState();
}

class _FarmerProductSelectionCardState
    extends State<FarmerProductSelectionCard> {
  String farmerName = 'Loading...';
  String farmerLocation = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadFarmerInfo();
  }

  void _loadFarmerInfo() async {
    final data = widget.product.data() as Map<String, dynamic>;
    final farmerId = data['farmerId'];

    if (farmerId != null) {
      try {
        final farmerDoc = await FirebaseFirestore.instance
            .collection('farmersData')
            .doc(farmerId)
            .get();

        if (farmerDoc.exists) {
          final farmerData = farmerDoc.data();
          if (mounted) {
            // Safely get farmer name with type checking
            final nameField = farmerData?['name'];
            final firstNameField = farmerData?['firstName'];
            final farmerNameField = farmerData?['farmerName'];
            final locationField = farmerData?['location'];
            final addressField = farmerData?['address'];

            String safeFarmerName = 'Unknown Farmer';
            if (nameField != null && nameField is String) {
              safeFarmerName = nameField;
            } else if (firstNameField != null && firstNameField is String) {
              safeFarmerName = firstNameField;
            } else if (farmerNameField != null && farmerNameField is String) {
              safeFarmerName = farmerNameField;
            }

            String safeFarmerLocation = 'Unknown Location';
            if (locationField != null && locationField is String) {
              safeFarmerLocation = locationField;
            } else if (addressField != null && addressField is String) {
              safeFarmerLocation = addressField;
            }

            setState(() {
              farmerName = safeFarmerName;
              farmerLocation = safeFarmerLocation;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            farmerName = 'Unknown Farmer';
            farmerLocation = 'Unknown Location';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.product.data() as Map<String, dynamic>;
    final formatter = NumberFormat('#,###');

    final price = (data['price'] ?? 0).toDouble();
    final formattedPrice = formatter.format(price);
    final imageUrl = data['imageUrl'] ?? '';
    final stock = (data['stock'] ?? 0).toInt();
    final minUnitNum = (data['minUnitNum'] ?? 1).toInt();

    // Handle unit type
    final dynamic unitTypeData = data['unit'] ?? 'unit';
    String unitType;
    if (unitTypeData is List && unitTypeData.isNotEmpty) {
      unitType = unitTypeData.first.toString();
    } else if (unitTypeData is String) {
      unitType = unitTypeData;
    } else {
      unitType = 'unit';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported_outlined),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),

                SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farmer Info
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          farmerName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              farmerLocation,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          Text(
                            '\$$formattedPrice',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                          Text(
                            '/$unitType',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4),

                      // Stock info
                      Text(
                        'In stock: $stock $unitType',
                        style: TextStyle(
                          fontSize: 12,
                          color: stock > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Quantity Selector
            if (stock > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),

                  Row(
                    children: [
                      // Decrease button
                      InkWell(
                        onTap: widget.quantity > 0
                            ? () => widget.onQuantityChanged(
                                (widget.quantity - minUnitNum).toInt(),
                              )
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.quantity > 0
                                ? Colors.red.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 20,
                            color: widget.quantity > 0
                                ? Colors.red.shade700
                                : Colors.grey,
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Quantity display
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Increase button
                      InkWell(
                        onTap: widget.quantity < stock
                            ? () => widget.onQuantityChanged(
                                (widget.quantity + minUnitNum).toInt(),
                              )
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.quantity < stock
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: widget.quantity < stock
                                ? Colors.green.shade700
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Out of Stock',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Total for this farmer
            if (widget.quantity > 0)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Total: \$${formatter.format(price * widget.quantity)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
