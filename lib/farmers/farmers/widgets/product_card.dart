import 'package:flutter/material.dart';
import 'package:denbigh_app/farmers/farmers/model/products.dart';
import 'package:denbigh_app/farmers/farmers/widgets/used_list/list.dart';

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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16.0),
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and description
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          //delete and edit buttons
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: onEdit,
                                icon: Icon(Icons.edit_note),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: onDelete,
                                icon: Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (product.description.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Text(
                          product.description,
                          style: TextStyle(fontSize: 14),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    SizedBox(height: 6),
                    // Price, Stock, Category
                    Row(
                      children: [
                        Text(
                          'Price: \$${product.price} / ${product.unit.first}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 14),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Stock: ${product.stock} ${product.unit.first}'), 
                        SizedBox(width: 14),
                        Row(
                          children: [
                            for (
                              int i = 0;
                              i < product.category.length;
                              i++
                            ) ...[
                              Chip(
                                label: Text(product.category[i]),
                                backgroundColor: categoryColors[product.category[i]] ?? Colors.grey.shade100,
                              ),
                              if (i != product.category.length - 1)
                                SizedBox(width: 4), // space between chips
                            ],
                          ],
                        ),
                      ],
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
