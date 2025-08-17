// // 1. Get all products from all farmers
// final allProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .get(); // Gets every product document

// // 2. Get all products for a specific farmer
// final farmerProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .where('farmerId', isEqualTo: 'FARMER_UID')
//     .get(); // Only products owned by this farmer

// // 3. Get all products in a specific category
// final vegProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .where('category', isEqualTo: 'Vegetables')
//     .get(); // Only products in "Vegetables" category

// // 4. Get all products for a farmer in a category
// final farmerVegProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .where('farmerId', isEqualTo: 'FARMER_UID')
//     .where('category', isEqualTo: 'Vegetables')
//     .get(); // Products matching both farmer and category

// // 5. Get all orders placed by a customer
// final customerOrders = await FirebaseFirestore.instance
//     .collection('orders')
//     .where('customerId', isEqualTo: 'CUSTOMER_UID')
//     .orderBy('createdAt', descending: true)
//     .get(); // Recent orders by customer

// // 6. Get all orders for a farmer (farmer’s received orders)
// final farmerOrders = await FirebaseFirestore.instance
//     .collection('orders')
//     .where('farmerId', isEqualTo: 'FARMER_UID')
//     .orderBy('createdAt', descending: true)
//     .get(); // Orders for this farmer

// // 7. Get all users with a specific role (e.g. all farmers)
// final farmers = await FirebaseFirestore.instance
//     .collection('users')
//     .where('role', isEqualTo: 'farmer')
//     .get(); // All users who are farmers

// // 8. Get all products in stock (stock > 0)
// final availableProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .where('stock', isGreaterThan: 0)
//     .get(); // Only products currently in stock

// // 9. Get products sorted by price, cheapest first
// final cheapProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .orderBy('price')
//     .get(); // All products, sorted by price (ascending)

// // 10. Get products created after a specific date
// final recentProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .where('createdAt', isGreaterThan: Timestamp.fromDate(DateTime(2025, 7, 1)))
//     .get(); // Products added after July 1, 2025

// // 11. Get products by multiple categories (using 'whereIn')
// final categories = ['Vegetables', 'Fruits', 'Dairy'];
// final multiCatProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .where('category', whereIn: categories)
//     .get(); // Products in any of the listed categories

// // 12. Get a single product by productId
// final productDoc = await FirebaseFirestore.instance
//     .collection('products')
//     .doc('PRODUCT_ID')
//     .get(); // Gets the specific product

// // 13. Compound query: products in category, in stock, sorted by price
// final filteredProducts = await FirebaseFirestore.instance
//     .collection('products')
//     .where('category', isEqualTo: 'Dairy')
//     .where('stock', isGreaterThan: 0)
//     .orderBy('stock')
//     .orderBy('price')
//     .get(); // Dairy products in stock, sorted by stock then price

// // 14. Get all sales for a specific farmer
// final farmerSales = await FirebaseFirestore.instance
//     .collection('sales')
//     .where('farmerId', isEqualTo: 'FARMER_UID')
//     .orderBy('date', descending: true)
//     .get(); // All sales for the farmer, most recent first

// // 15. Get all users signed up after a certain date
// final newUsers = await FirebaseFirestore.instance
//     .collection('users')
//     .where('createdAt', isGreaterThan: Timestamp.fromDate(DateTime(2025, 7, 1)))
//     .get(); // Users who signed up after July 1, 2025