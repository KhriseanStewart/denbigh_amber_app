import 'package:denbigh_app/farmers/model/products.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if stock is low (at or below minimum sales amount)
    final minUnitNum = int.tryParse(product.minUnitNum) ?? 0;
    final isLowStock = product.stock <= minUnitNum && minUnitNum > 0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isLowStock ? Color(0xFFFFEBEE) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock
              ? Color(0xFFE57373)
              : Color(0xFF4CAF50).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isLowStock
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with warning for low stock
                    if (isLowStock)
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFE57373),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Low Stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Title and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: onEdit,
                                icon: Icon(
                                  Icons.edit_note,
                                  color: Color(0xFF4CAF50),
                                ),
                                iconSize: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: onDelete,
                                icon: Icon(
                                  Icons.delete,
                                  color: Color(0xFFE57373),
                                ),
                                iconSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (product.description.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    SizedBox(height: 16),

                    // Price and Details
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF4CAF50).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Color(0xFF4CAF50),
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              Text(
                                ' / ${product.unit.isNotEmpty ? product.unit.first : 'unit'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Stock info
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    color: isLowStock
                                        ? Color(0xFFE57373)
                                        : Color(0xFF4CAF50),
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isLowStock
                                          ? Color(0xFFE57373)
                                          : Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                              // Category
                              if (product.category.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    product.category.first,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}
