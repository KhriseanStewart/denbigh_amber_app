import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/routes.dart';
import 'package:denbigh_app/users/database/multi_farmer_product_service.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FarmersSellingProductScreen extends StatelessWidget {
  final String productName;

  const FarmersSellingProductScreen({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("F4F6F8"),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Farmers selling "$productName"',
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
          productName,
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
                    'No farmers selling "$productName" found',
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
              return FarmerProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}

class FarmerProductCard extends StatelessWidget {
  final QueryDocumentSnapshot product;

  const FarmerProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    final formatter = NumberFormat('#,###');

    final price = data['price'] ?? 0;
    final formattedPrice = formatter.format(price);

    final farmerId = data['farmerId'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to product detail screen
          Navigator.pushNamed(
            context,
            AppRouter.productdetail,
            arguments: product,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  child: data['imageUrl'] != null
                      ? Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
              SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      data['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Farmer Info
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('farmers')
                          .doc(farmerId)
                          .get(),
                      builder: (context, farmerSnapshot) {
                        String farmerName = 'Unknown Farmer';
                        if (farmerSnapshot.hasData &&
                            farmerSnapshot.data!.exists) {
                          final farmerData =
                              farmerSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                          farmerName =
                              farmerData?['name'] ??
                              farmerData?['firstName'] ??
                              'Unknown Farmer';
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Farmer: $farmerName',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),

                    // Price and Unit
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
                          '/${data['unitType'] ?? 'unit'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    // Category and Stock
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (data['category'] != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              data['category'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                        if (data['quantity'] != null)
                          Text(
                            'Stock: ${data['quantity']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price comparison indicator (if multiple farmers)
              Icon(Icons.compare_arrows, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
