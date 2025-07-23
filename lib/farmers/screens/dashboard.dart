// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/screens/add_pruducts.dart'
    as add_product_screen;
import 'package:denbigh_app/farmers/screens/components/summary_card.dart';
import 'package:denbigh_app/farmers/screens/product_detail.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/simulation/ordersim.dart';
import 'package:denbigh_app/farmers/widgets/product_card.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

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
      final newDoc = await productsRef.add({'createdAt': Timestamp.now()});

      await newDoc.update({'id': newDoc.id});

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<farmer_auth.AuthService>.value(
            value: Provider.of<farmer_auth.AuthService>(context, listen: false),
            child: add_product_screen.AddProductScreen(productId: newDoc.id),
          ),
        ),
      );
    }

    final auth = Provider.of<farmer_auth.AuthService>(context);
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
                  return buildSnapShotError();
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
                    double totalRevenueFromSales = 0.0;
                    int totalQuantitySold = 0;

                    if (salesSnapshot.hasData &&
                        salesSnapshot.data!.docs.isNotEmpty) {
                      for (final doc in salesSnapshot.data!.docs) {
                        final saleData = doc.data() as Map<String, dynamic>;
                        totalRevenueFromSales +=
                            (saleData['totalPrice'] as num?)?.toDouble() ?? 0.0;
                        totalQuantitySold +=
                            (saleData['quantity'] as num?)?.toInt() ?? 0;
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
                                      product: p as Product,
                                      onEdit: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChangeNotifierProvider<
                                                  farmer_auth.AuthService
                                                >.value(
                                                  value:
                                                      Provider.of<
                                                        farmer_auth.AuthService
                                                      >(context, listen: false),
                                                  child:
                                                      add_product_screen.AddProductScreen(
                                                        productId:
                                                            (p as Product)
                                                                .productId,
                                                        product: p as Product,
                                                      ),
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
                          AllFarmersProductOrderButton(
                            customerId: "SOME_CUSTOMER_ID",
                          ),
                          SizedBox(height: 16),
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
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/farmerlogin');
            },
            child: Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Center buildSnapShotError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text('Error loading products'),
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
                    final auth = Provider.of<farmer_auth.AuthService>(
                      context,
                      listen: false,
                    );
                    await auth.signOut();
                    Navigator.of(context).pop();
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
