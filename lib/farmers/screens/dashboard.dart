// ignore_for_file: unnecessary_cast

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
      backgroundColor: Color(0xFFF8FBF8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Farm Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  auth.farmer?.farmerName ?? 'No Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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
                    // Calculate totals from sales data
                    int totalRevenueFromSales = 0;
                    int totalQuantitySold = 0;

                    if (salesSnapshot.hasData &&
                        salesSnapshot.data!.docs.isNotEmpty) {
                      for (final doc in salesSnapshot.data!.docs) {
                        final saleData = doc.data() as Map<String, dynamic>;
                        totalRevenueFromSales +=
                            (saleData['totalPrice'] as num?)?.toInt() ?? 0;
                        totalQuantitySold +=
                            (saleData['quantity'] as num?)?.toInt() ?? 0;
                      }
                    }

                    final totalStock = products.fold<int>(
                      0,
                      (sum, p) => sum + p.stock,
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Header
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.dashboard,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Farm Overview',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Welcome back, ${auth.farmer?.farmerName ?? 'Farmer'}!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Statistics Cards
                          Text(
                            'Farm Statistics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 16),
                          Column(
                            spacing: 4,
                            children: [
                              Row(
                                spacing: 4,
                                children: [
                                  SummaryCard(
                                    'Total \nProducts',
                                    '${products.length}',
                                    Icon(FontAwesomeIcons.chartBar),
                                  ),
                                  SummaryCard(
                                    'Total \nRevenue',
                                    '\$${totalRevenueFromSales.toStringAsFixed(2)}',
                                    Icon(FeatherIcons.dollarSign),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 4,
                                children: [
                                  SummaryCard(
                                    'Total \nStock',
                                    '$totalStock',
                                    Icon(FontAwesomeIcons.box),
                                  ),
                                  SummaryCard(
                                    'Total \nSales',
                                    '$totalQuantitySold',
                                    Icon(FeatherIcons.shoppingCart),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                          // Products Section
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory,
                                          color: Color(0xFF4CAF50),
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'My Products',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF66BB6A),
                                            Color(0xFF4CAF50),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(
                                              0.3,
                                            ),
                                            spreadRadius: 0,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Add Product',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onPressed: () async {
                                          submitProduct();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                ...products.map(
                                  (p) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: ProductCard(
                                      product: p as Product,
                                      onEdit: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                add_product_screen.AddProductScreen(
                                                  productId:
                                                      (p as Product).productId,
                                                  product: p as Product,
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
                                            (p as Product).productId,
                                          );
                                        }
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProductDetailsScreen(
                                                  product: p as Product,
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
