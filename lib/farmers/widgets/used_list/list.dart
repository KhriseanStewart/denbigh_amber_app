

import 'package:flutter/material.dart';

final List<String> categories = [
  'Vegetables',
  'Fruits',
  'Dairy',
  'Grains',
  'Meat',
  'Poultry',
  'Seafood',
];

final List<String> units = [
  'kg',
  'dozen',
  'box',
  'bag',
  'carton',
  'pack',
  'LBS',
  'ounce',
];

final Map<String, Color> categoryColors = {
  'Vegetables': Colors.green.shade100,
  'Fruits': Colors.orange.shade100,
  'Dairy': Colors.blue.shade100,
  'Grains': Colors.brown.shade100,
  'Meat': Colors.red.shade100,
  'Bakery': Colors.amber.shade100,
  'Beverages': Colors.cyan.shade100,
  'Seafood': Colors.teal.shade100,
};

final Map<String, Color> statuses = {
  'processing': Colors.yellow,
  'shipped': Colors.blue,
  'delivered': Colors.green,
  'completed': Colors.grey,
  'cancelled': Colors.red,
};
