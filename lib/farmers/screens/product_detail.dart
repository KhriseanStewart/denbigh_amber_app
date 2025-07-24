import 'package:cached_network_image/cached_network_image.dart';
import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/model/sales.dart';
import 'package:denbigh_app/farmers/screens/add_pruducts.dart';
import 'package:denbigh_app/farmers/services/auth.dart' as farmer_auth;
import 'package:denbigh_app/farmers/services/sales_order.services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product _product;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    // Listen to product changes to update when sales are recorded
    _listenToProductUpdates();
  }

  void _listenToProductUpdates() {
    FirebaseFirestore.instance
        .collection('products')
        .doc(_product.productId)
        .snapshots()
        .listen((doc) {
          if (doc.exists && mounted) {
            setState(() {
              _product = Product.fromMap(doc.data()!, doc.id);
            });
          }
        });
  }

  void _updateProduct(Product newProduct) {
    setState(() {
      _product = newProduct;
    });
  }

  Future<void> _deleteProduct(BuildContext context) async {
    setState(() {
      _deleting = true;
    });
    try {
      if (_product.imageUrl.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('product_pictures')
              .child(_product.productId);
          await ref.delete();
        } catch (_) {}
      }
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_product.productId)
          .delete();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _deleting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _editProduct() async {
    final updatedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute(
        builder: (_) =>
            AddProductScreen(productId: _product.productId, product: _product),
      ),
    );
    if (updatedProduct != null) {
      _updateProduct(updatedProduct);
    }
  }
  //

  //it ends here

  @override
  Widget build(BuildContext context) {
    final salesService = SalesAndOrdersService();

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: _editProduct,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[700]),
            onPressed: _deleting
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Delete Product'),
                        content: Text(
                          'Are you sure you want to delete this product? This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deleteProduct(context);
                    }
                  },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_product.imageUrl.isNotEmpty)
                Center(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(_product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 24),
              Text(
                _product.name,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(_product.description, style: TextStyle(fontSize: 18)),
              SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ..._product.category.map((cat) => Chip(label: Text(cat))),
                  _DetailChip(
                    label:
                        'Price: ${_product.price} / ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                  ),
                  _DetailChip(
                    label:
                        'Min. Sale: ${_product.minUnitNum} ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                  ),
                  // Current Stock and Total Sold/Earnings will be calculated from sales data below
                ],
              ),
              SizedBox(height: 16),
              // Product statistics: Stock from Firestore, Sales data from actual sales
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(_product.productId)
                    .snapshots(),
                builder: (context, productSnapshot) {
                  // Get current stock from Firestore (single source of truth)
                  int currentStock = _product.stock;

                  if (productSnapshot.hasData && productSnapshot.data!.exists) {
                    final data =
                        productSnapshot.data!.data() as Map<String, dynamic>;
                    currentStock = data['stock'] ?? 0;
                  }

                  // Get sales data for total sold and earnings calculation
                  return StreamBuilder<List<Sale>>(
                    stream: salesService.getSalesForProduct(
                      _product.productId,
                      _product.farmerId,
                    ),
                    builder: (context, salesSnapshot) {
                      // Calculate totals from actual sales data
                      int totalSoldFromSales = 0;
                      double totalEarningsFromSales = 0.0;

                      if (salesSnapshot.hasData &&
                          salesSnapshot.data!.isNotEmpty) {
                        for (final sale in salesSnapshot.data!) {
                          totalSoldFromSales += sale.quantity;
                          totalEarningsFromSales += sale.totalPrice;
                        }
                      }

                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _DetailChip(
                            label:
                                'Current Stock: $currentStock ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                          ),
                          _DetailChip(
                            label:
                                'Total Sold: $totalSoldFromSales ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                          ),
                          _DetailChip(
                            label:
                                'Total Earnings: \$${totalEarningsFromSales.toStringAsFixed(2)}',
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 24),
              Text(
                'Sales History',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              StreamBuilder<List<Sale>>(
                stream: salesService.getSalesForProduct(
                  _product.productId,
                  _product.farmerId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Error loading sales: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'No sales yet. Orders will appear here when converted to sales.',
                      ),
                    );
                  }

                  final sales = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Sales: ${sales.length}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: sales.length,
                        separatorBuilder: (c, i) => Divider(),
                        itemBuilder: (context, index) {
                          final s = sales[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: Colors.green[800],
                                ),
                              ),
                              title: Text(
                                'Qty: ${s.quantity} ${s.unit} @ \$${(s.totalPrice / s.quantity).toStringAsFixed(2)} each',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer: ${s.customerId}'),
                                  Text(
                                    'Total: \$${s.totalPrice.toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    'Date: ${s.date.toDate().toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  const _DetailChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
