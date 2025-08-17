






import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageDisplay extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double borderRadius;

  const ProductImageDisplay({
    super.key,
    required this.imageUrl,
    this.height = 300,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const SizedBox(); // Or a placeholder widget
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            image: DecorationImage(
              image: CachedNetworkImageProvider(imageUrl),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}