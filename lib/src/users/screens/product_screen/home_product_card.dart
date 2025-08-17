import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatefulWidget {
  final QueryDocumentSnapshot data;
  const ProductCard({super.key, required this.data});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    // --- Start of Changes ---

    // Safely get the data from Firestore, providing default values to prevent errors.
    final String name = data['name'] ?? 'No Name Available';
    final String imageUrl = data['imageUrl'] ?? ''; // Default to empty string
    final int price = data['price'] ?? 0;
    final String category = data['category'] ?? 'Uncategorized';
    final String unitType = data['unitType'] ?? 'unit';

    // Format the price safely
    final formatter = NumberFormat('#,###');
    final displayNumber = formatter.format(price);

    // --- End of Changes ---

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade300,
        //     blurRadius: 4,
        //     offset: Offset(0, 0.5),
        //   ),
        // ],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              // --- Change: Check if imageUrl is not empty before trying to display it ---
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl, // Use the safe variable
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported_outlined);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade300,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(color: Colors.grey),
                            ),
                          );
                        }
                      },
                    )
                  : Container(
                      // Show a placeholder if no imageUrl exists
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            name, // Use the safe variable
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category, // Use the safe variable
              style: TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$$displayNumber", // Already safe from the check above
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                "/$unitType", // Use the safe variable
                style: TextStyle(color: Colors.black),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
