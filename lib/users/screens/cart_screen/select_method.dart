import 'package:denbigh_app/users/screens/cart_screen/select_payment_method.dart';
import 'package:flutter/material.dart';

class SelectMethod extends StatelessWidget {
  const SelectMethod({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          PaymentMethodRow(
            methodName: 'VISA',
            fullName: 'John Doe',
            onSelect: () {
              // Handle select action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('VISA selected')),
              );
            },
            onEdit: () {
              // Handle edit action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit VISA method')),
              );
            },
          ),
        ],
      ),
    );
  }
}