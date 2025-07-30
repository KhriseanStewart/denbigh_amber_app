import 'package:flutter/material.dart';

class PaymentMethodRow extends StatelessWidget {
  final String methodName; // e.g., 'VISA', 'PayPal'
  final String fullName; // e.g., user's name or username
  final VoidCallback onSelect; // callback when select button is tapped
  final VoidCallback onEdit; // callback when edit arrow is tapped

  const PaymentMethodRow({
    Key? key,
    required this.methodName,
    required this.fullName,
    required this.onSelect,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Select Button
        ElevatedButton(onPressed: onSelect, child: Text('Select')),
        const SizedBox(width: 12),
        // Middle Text Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                methodName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                fullName,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        // Edit Icon Button
        IconButton(icon: Icon(Icons.arrow_forward), onPressed: onEdit),
      ],
    );
  }
}
