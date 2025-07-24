import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Icon icon;

  const SummaryCard(this.label, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListTile(
          title: Text(label, style: TextStyle(fontSize: 16)),
          subtitle: Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          trailing: icon,
        ),
      ),
    );
  }
}
