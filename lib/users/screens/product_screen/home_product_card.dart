import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: Offset(0, 0.5),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(10),
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
                "https://agrilinkages.gov.jm/storage/product/649/image/Screenshot_20250611_123227_Google_1749664701.jpg",
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
            "Ripe Banana",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("Legumes", style: TextStyle(fontSize: 14)),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                "\$120.00",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text("/per hand", style: TextStyle(color: Colors.black)),
              Spacer(),
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
