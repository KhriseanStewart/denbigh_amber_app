// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/farmers/model/products.dart';
import 'package:denbigh_app/farmers/farmers/screens/add_pruducts.dart'
    as add_product_screen;
import 'package:denbigh_app/farmers/farmers/screens/product_detail.dart';
import 'package:denbigh_app/farmers/farmers/services/auth.dart';
import 'package:denbigh_app/farmers/farmers/widgets/product_card.dart';
import 'package:denbigh_app/farmers/simulation/ordersim.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:flutter/material.dart';
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
    final productService = ProductService();
    final uid = auth!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          Icon(Icons.person),
          SizedBox(width: 8),
          Text('Farmer name'),
          // Text(auth.farmer?.email ?? ''),
          SizedBox(width: 8),
          _logout(context),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProductsForFarmer(uid),
        builder: (context, productSnapshot) {
          if (!productSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final products = productSnapshot.data!;

          // Get sales data for revenue and total sales calculation
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sales')
                .where('farmerId', isEqualTo: uid)
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
                      children: [
                        Row(
                          children: [
                            _SummaryCard(
                              'Total Products',
                              '${products.length}',
                              '📦',
                            ),
                            _SummaryCard(
                              'Revenue',
                              '\$${totalRevenueFromSales.toStringAsFixed(2)}',
                              '💰',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _SummaryCard('Total Stock', '$totalStock', '📊'),
                            _SummaryCard(
                              'Total Sales',
                              '$totalQuantitySold',
                              '📈',
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                icon: Icon(Icons.add),
                                label: Text(
                                  'Add Product',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  final productsRef = FirebaseFirestore.instance
                                      .collection('products');
                                  final newDoc = await productsRef.add({
                                    'createdAt': Timestamp.now(),
                                  });

                                  await newDoc.update({'id': newDoc.id});

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          add_product_screen.AddProductScreen(
                                            productId: newDoc.id,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ...products.map(
                            (p) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: ProductCard(
                                product: p as Product,
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          add_product_screen.AddProductScreen(
                                            productId: (p as Product).productId,
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
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
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
                                      builder: (_) => ProductDetailsScreen(
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
                  ],
                ),
              );
            },
          );
        },
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
                    final auth = Provider.of<AuthService>(
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _SummaryCard(this.label, this.value, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(emoji, style: TextStyle(fontSize: 30)),
                ],
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
