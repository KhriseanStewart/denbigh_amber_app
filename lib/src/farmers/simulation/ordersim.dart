import 'package:flutter/material.dart';

class AllFarmersProductOrderButton extends StatelessWidget {
  final String customerId;

  const AllFarmersProductOrderButton({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.info),
      label: Text('Demo: Order Flow'),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Customer ID: $customerId\nUse the user app to add items to cart and checkout for proper order flow',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
