import 'package:cached_network_image/cached_network_image.dart';
import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/model/sales.dart';
import 'package:denbigh_app/farmers/screens/add_pruducts.dart';

import 'package:denbigh_app/farmers/services/sales_order.services.dart';
import 'package:flutter/material.dart';

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
        title: Text(
          _product.name,
          style: TextStyle(
            fontFamily: 'Switzer',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: _editProduct,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: _deleting
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red[600]),
                              SizedBox(width: 8),
                              Text(
                                'Delete Product',
                                style: TextStyle(
                                  fontFamily: 'Switzer',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            'Are you sure you want to delete this product? This cannot be undone.',
                            style: TextStyle(fontFamily: 'Switzer'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: 'Switzer',
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Delete',
                                style: TextStyle(fontFamily: 'Switzer'),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _deleteProduct(context);
                      }
                    },
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF1F8E9), // Light agricultural green background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.2),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(_product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFF8FFF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.eco, color: Color(0xFF4CAF50), size: 28),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _product.name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Switzer',
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        _product.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Switzer',
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4CAF50).withOpacity(0.1),
                        Color(0xFF66BB6A).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Product Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Switzer',
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._product.category.map(
                            (cat) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF66BB6A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Switzer',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          _EnhancedDetailChip(
                            icon: Icons.attach_money,
                            label:
                                'Price: \$${_product.price} / ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                          ),
                          _EnhancedDetailChip(
                            icon: Icons.shopping_cart,
                            label:
                                'Min. Sale: ${_product.minUnitNum} ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Product statistics: Stock from Firestore, Sales data from actual sales
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF66BB6A).withOpacity(0.1),
                        Color(0xFF4CAF50).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF66BB6A).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Product Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Switzer',
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .doc(_product.productId)
                            .snapshots(),
                        builder: (context, productSnapshot) {
                          // Get current stock from Firestore (single source of truth)
                          int currentStock = _product.stock;

                          if (productSnapshot.hasData &&
                              productSnapshot.data!.exists) {
                            final data =
                                productSnapshot.data!.data()
                                    as Map<String, dynamic>;
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
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _EnhancedDetailChip(
                                    icon: Icons.inventory,
                                    label:
                                        'Current Stock: $currentStock ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                                    color: currentStock > 10
                                        ? Color(0xFF4CAF50)
                                        : Colors.orange,
                                  ),
                                  _EnhancedDetailChip(
                                    icon: Icons.trending_up,
                                    label:
                                        'Total Sold: $totalSoldFromSales ${_product.unit.isNotEmpty ? _product.unit.first : ''}',
                                    color: Color(0xFF2196F3),
                                  ),
                                  _EnhancedDetailChip(
                                    icon: Icons.monetization_on,
                                    label:
                                        'Total Earnings: \$${totalEarningsFromSales.toStringAsFixed(2)}',
                                    color: Color(0xFF4CAF50),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFF8FFF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sales History',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Switzer',
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      StreamBuilder<List<Sale>>(
                        stream: salesService.getSalesForProduct(
                          _product.productId,
                          _product.farmerId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[600],
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Error loading sales: ${snapshot.error}',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontFamily: 'Switzer',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xFF4CAF50).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 48,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No sales yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E7D32),
                                      fontFamily: 'Switzer',
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Orders will appear here when converted to sales.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontFamily: 'Switzer',
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF66BB6A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.assessment,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Total Sales: ${sales.length}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Switzer',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: sales.length,
                                separatorBuilder: (c, i) => SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final s = sales[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFFF8FFF8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(
                                          0xFF4CAF50,
                                        ).withOpacity(0.2),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(12),
                                      leading: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF4CAF50),
                                              Color(0xFF66BB6A),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        'Qty: ${s.quantity} ${s.unit} @ \$${(s.totalPrice / s.quantity).toStringAsFixed(2)} each',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Switzer',
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                            'Customer: ${s.customerId}',
                                            style: TextStyle(
                                              fontFamily: 'Switzer',
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            'Total: \$${s.totalPrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF4CAF50),
                                              fontFamily: 'Switzer',
                                            ),
                                          ),
                                          Text(
                                            'Date: ${s.date.toDate().toLocal().toString().split(' ')[0]}',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontFamily: 'Switzer',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Color(0xFF4CAF50),
                                        ),
                                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnhancedDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _EnhancedDetailChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Color(0xFF4CAF50);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [chipColor.withOpacity(0.1), chipColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'Switzer',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
