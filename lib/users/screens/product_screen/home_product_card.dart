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
    //function to turn int to string with ,s
    final numberFromFirebase = data['price'] ?? ''; // Example fetched data
    final formatter = NumberFormat('#,###');
    final displayNumber = formatter.format(numberFromFirebase);
    //
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
          // Use Expanded to fill available space
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                //TODO: ADD FIRESTORE STORAGE LINK
                data['imageUrl'],
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
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            data['name'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "\$$displayNumber",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "/${data['unitType']}",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${data['category'] ?? 'null'}",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              //TODO: to be added back probably
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(Icons.add),
              //   style: IconButton.styleFrom(
              //     backgroundColor: Colors.black,
              //     foregroundColor: Colors.white,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
