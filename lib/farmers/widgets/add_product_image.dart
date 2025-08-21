import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageDisplay extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double borderRadius;
  final VoidCallback? onTap;

  const ProductImageDisplay({
    super.key,
    required this.imageUrl,
    this.height = 300,
    this.borderRadius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const SizedBox(); // Or a placeholder widget
    }

    Widget imageWidget = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey[400],
                  size: 50,
                ),
              ),
            ),
          ),
          // Change image overlay
          if (onTap != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: onTap != null
            ? GestureDetector(onTap: onTap, child: imageWidget)
            : imageWidget,
      ),
    );
  }
}
