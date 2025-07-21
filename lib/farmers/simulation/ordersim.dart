import 'package:denbigh_app/farmers/model/orders.dart';
import 'package:denbigh_app/farmers/model/products.dart';
import 'package:denbigh_app/farmers/services/sales_order.services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllFarmersProductOrderButton extends StatelessWidget {
  final String customerId;

  const AllFarmersProductOrderButton({super.key, required this.customerId});

  Future<List<Product>> _getAllProducts() async {
    final query = await FirebaseFirestore.instance.collection('products').get();
    return query.docs
        .map(
          (doc) =>
              Product.fromMap({...doc.data(), 'productId': doc.id}, doc.id),
        )
        .toList();
  }

  void _showProductSelection(BuildContext context) async {
    final products = await _getAllProducts();
    if (products.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No products available.')));
      }
      return;
    }

    // Show the selection dialog/screen
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductSelectionScreen(
            products: products,
            customerId: customerId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.shopping_cart),
      label: Text('Order from ALL Farmers'),
      onPressed: () => _showProductSelection(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ProductSelectionScreen extends StatefulWidget {
  final List<Product> products;
  final String customerId;

  const ProductSelectionScreen({
    super.key,
    required this.products,
    required this.customerId,
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final Map<String, int> _selectedQuantities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Products')),
      body: ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (context, idx) {
          final product = widget.products[idx];
          final qty = _selectedQuantities[product.productId] ?? 0;
          return ListTile(
            title: Text(product.name),
            subtitle: Text(
              'Farmer: ${product.farmerId}\nPrice: ${product.price}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: qty > 0
                      ? () => setState(() {
                          _selectedQuantities[product.productId] = qty - 1;
                        })
                      : null,
                ),
                Text(qty.toString()),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => setState(() {
                    _selectedQuantities[product.productId] = qty + 1;
                  }),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Collect selected items
          final selectedItems = <OrderItem>[];
          widget.products.forEach((prod) {
            final qty = _selectedQuantities[prod.productId] ?? 0;
            if (qty > 0) {
              selectedItems.add(
                OrderItem(
                  orderId:
                      '', // Will be set when creating the order by firestore
                  customerLocation: prod.customerLocation,
                  productId: prod.productId,
                  unit: prod.unit.isNotEmpty ? prod.unit.first : 'unit',
                  name: prod.name,
                  quantity: qty,
                  price: prod.price,
                  imageUrl: prod.imageUrl,
                  farmerId: prod.farmerId,
                ),
              );
            }
          });

          if (selectedItems.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No products selected.')),
              );
            }
            return;
          }

          final orderService = SalesAndOrdersService();
          int orderCount = 0;
          for (final item in selectedItems) {
            final order = Orderlist(
              customerLocation: item.customerLocation,
              quantity: item.quantity.toString(),
              orderId: '',
              name: item.name,
              customerId: widget.customerId,
              farmerId: item.farmerId,
              unit: item.unit,
              items: [item], // Only one item per order!
              totalPrice: item.price * item.quantity,
              status: 'processing',
              createdAt: DateTime.now(),
              imageUrl: item.imageUrl,
            );
            await orderService.createOrder(order);
            orderCount++;
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Created $orderCount orders!')),
            );
            Navigator.of(context).pop();
          }
        },
        label: Text('Place Order'),
        icon: Icon(Icons.check),
      ),
    );
  }
}
