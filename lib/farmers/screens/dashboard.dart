

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/screens/add_pruducts.dart'
    as add_product_screen;
import 'package:denbigh_app/farmers/screens/components/summary_card.dart';
import 'package:denbigh_app/farmers/screens/product_detail.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/widgets/product_card.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/product_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    void submitProduct() async {
      final productsRef = FirebaseFirestore.instance.collection('products');
      final newDoc = await productsRef.add({
        'createdAt': Timestamp.now(),
        'isComplete': false, // Mark as incomplete initially
        'isActive': false, // Not visible to users yet
      });

      await newDoc.update({'id': newDoc.id});

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              add_product_screen.AddProductScreen(productId: newDoc.id),
        ),
      );
    }

    final auth = farmer_auth.AuthService();
    final productService = ProductService();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Dashboard'),
        actions: [
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
          Text(auth.farmer?.farmerName ?? 'No Name'),
          SizedBox(width: 8),
          _logout(context),
        ],
      ),
      body: auth.farmer == null
          ? buildNullFarmer(context)
          : StreamBuilder<List<Product>>(
              stream: productService.getProductsForFarmer(auth.farmer!.id),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (productSnapshot.hasError) {
                  print('Error loading products: ${productSnapshot.error}');
                  return buildSnapShotError(productSnapshot.error);
                }

                if (!productSnapshot.hasData) {
                  return Center(child: Text('No data received'));
                }

                final products = productSnapshot.data!;

                // Get sales data for revenue and total sales calculation
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sales')
                      .where('farmerId', isEqualTo: auth.farmer!.id)
                      .snapshots(),
                  builder: (context, salesSnapshot) {
                    // Calculate totals from sales data (handle both consolidated and individual sales)
                    int totalRevenueFromSales = 0;
                    int totalQuantitySold = 0;

                    if (salesSnapshot.hasData &&
                        salesSnapshot.data!.docs.isNotEmpty) {
                      for (final doc in salesSnapshot.data!.docs) {
                        final saleData = doc.data() as Map<String, dynamic>;

                        // Handle consolidated sales (with items array)
                        if (saleData.containsKey('items') &&
                            saleData['items'] is List) {
                          final items = saleData['items'] as List<dynamic>;

                          // Calculate revenue from total sale amount
                          totalRevenueFromSales +=
                              (saleData['totalPrice'] as num?)?.toInt() ?? 0;

                          // Calculate quantity from all items in this sale
                          for (var item in items) {
                            totalQuantitySold +=
                                (item['quantity'] as num?)?.toInt() ?? 0;
                          }
                        } else {
                          // Handle individual sales (old format)
                          totalRevenueFromSales +=
                              (saleData['totalPrice'] as num?)?.toInt() ?? 0;
                          totalQuantitySold +=
                              (saleData['quantity'] as num?)?.toInt() ?? 0;
                        }
                      }
                    }

                    final totalStock = products.fold<int>(
                      0,
                      (sum, p) => sum + p.stock,
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Column(
                            spacing: 4,
                            children: [
                              Row(
                                spacing: 4,
                                children: [
                                  SummaryCard(
                                    'Total \nProducts',
                                    '${products.length}',
                                    Icon(FontAwesomeIcons.chartBar, color: Colors.orange.shade300),
                                  ),
                                  SummaryCard(
                                    'Total \nRevenue',
                                    '\$${totalRevenueFromSales.toStringAsFixed(2)}',
                                    Icon(FeatherIcons.dollarSign, color: Colors.orange.shade300),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 4,
                                children: [
                                  SummaryCard(
                                    'Total \nStock',
                                    '$totalStock',
                                    Icon(FontAwesomeIcons.box, color: Colors.orange.shade300),
                                  ),
                                  SummaryCard(
                                    'Total \nSales',
                                    '$totalQuantitySold',
                                    Icon(FeatherIcons.shoppingCart, color: Colors.orange.shade300),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'My Products',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'Add Product',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        submitProduct();
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                ...products.map(
                                  (p) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: ProductCard(
                                      product: p,
                                      onEdit: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                add_product_screen.AddProductScreen(
                                                  productId:
                                                      (p).productId,
                                                  product: p,
                                                ),
                                          ),
                                        );
                                      },
                                      onDelete: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text('Delete Product'),
                                            content: Text(
                                              'Are you sure you want to delete this product?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                                child: Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await ProductService().deleteProduct(
                                            (p).productId,
                                          );
                                        }
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProductDetailsScreen(
                                                  product: p,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                if (products.isEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'No products available. Add your first product!',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Center buildNullFarmer(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading farmer data...'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                await farmer_auth.AuthService().signOut();
                Navigator.pushReplacementNamed(context, '/farmerlogin');
              } catch (e) {
                print('Logout error: $e');
              }
            },
            child: Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Center buildSnapShotError([Object? error]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text('Error loading products'),
          if (error != null) ...[
            SizedBox(height: 8),
            Text(
              'Details: ${error.toString()}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _logout(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout, color: Colors.red),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Logout?'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      Navigator.of(context).pop(); // Close dialog first
                      await farmer_auth.AuthService().signOut();
                      Navigator.pushReplacementNamed(context, '/farmerlogin');
                    } catch (e) {
                      print('Logout error: $e');
                      // Show error message if needed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: $e')),
                      );
                    }
                  },
                  child: Text('Logout'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
