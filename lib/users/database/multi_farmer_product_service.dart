import 'package:cloud_firestore/cloud_firestore.dart';

class MultiFarmerProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all products grouped by product name
  /// Returns a map where key is product name and value is list of products from different farmers
  Future<Map<String, List<QueryDocumentSnapshot>>>
  getProductsGroupedByName() async {
    final snapshot = await _db.collection('products').get();

    Map<String, List<QueryDocumentSnapshot>> groupedProducts = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final productName = data['name']?.toString().toLowerCase() ?? '';

      if (productName.isNotEmpty) {
        if (!groupedProducts.containsKey(productName)) {
          groupedProducts[productName] = [];
        }
        groupedProducts[productName]!.add(doc);
      }
    }

    return groupedProducts;
  }

  /// Get all farmers selling a specific product name
  Stream<List<QueryDocumentSnapshot>> getFarmersSellingProduct(
    String productName,
  ) {
    return _db
        .collection('products')
        .where('name', isEqualTo: productName)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// Get products with farmer information for display
  Stream<List<Map<String, dynamic>>> getProductsWithFarmerInfo() {
    return _db.collection('products').snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> productsWithFarmers = [];

      for (var doc in snapshot.docs) {
        final productData = doc.data();
        final farmerId = productData['farmerId'];

        // Get farmer information
        String farmerName = 'Unknown Farmer';
        if (farmerId != null) {
          try {
            final farmerDoc = await _db
                .collection('farmers')
                .doc(farmerId)
                .get();
            if (farmerDoc.exists) {
              final farmerData = farmerDoc.data();
              farmerName =
                  farmerData?['name'] ??
                  farmerData?['firstName'] ??
                  'Unknown Farmer';
            }
          } catch (e) {
            print('Error fetching farmer info: $e');
          }
        }

        productsWithFarmers.add({
          'productId': doc.id,
          'farmerName': farmerName,
          'farmerId': farmerId,
          ...productData,
        });
      }

      return productsWithFarmers;
    });
  }

  /// Search products by name and return all farmers selling matching products
  Stream<List<Map<String, dynamic>>> searchProductsWithFarmers(
    String searchQuery,
  ) {
    return _db.collection('products').snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> matchingProducts = [];

      for (var doc in snapshot.docs) {
        final productData = doc.data();
        final productName = productData['name']?.toString().toLowerCase() ?? '';
        final category =
            productData['category']?.toString().toLowerCase() ?? '';
        final description =
            productData['description']?.toString().toLowerCase() ?? '';

        final query = searchQuery.toLowerCase();

        // Check if search query matches name, category, or description
        if (productName.contains(query) ||
            category.contains(query) ||
            description.contains(query)) {
          final farmerId = productData['farmerId'];

          // Get farmer information
          String farmerName = 'Unknown Farmer';
          if (farmerId != null) {
            try {
              final farmerDoc = await _db
                  .collection('farmers')
                  .doc(farmerId)
                  .get();
              if (farmerDoc.exists) {
                final farmerData = farmerDoc.data();
                farmerName =
                    farmerData?['name'] ??
                    farmerData?['firstName'] ??
                    'Unknown Farmer';
              }
            } catch (e) {
              print('Error fetching farmer info: $e');
            }
          }

          matchingProducts.add({
            'productId': doc.id,
            'farmerName': farmerName,
            'farmerId': farmerId,
            ...productData,
          });
        }
      }

      return matchingProducts;
    });
  }

  /// Get all unique product names (for showing grouped products)
  Stream<List<String>> getUniqueProductNames() {
    return _db.collection('products').snapshots().map((snapshot) {
      Set<String> uniqueNames = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name']?.toString();
        if (name != null && name.isNotEmpty) {
          uniqueNames.add(name);
        }
      }

      return uniqueNames.toList()..sort();
    });
  }

  /// Filter products by category with farmer information
  Stream<List<Map<String, dynamic>>> getProductsByCategoryWithFarmers(
    String category,
  ) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> productsWithFarmers = [];

          for (var doc in snapshot.docs) {
            final productData = doc.data();
            final farmerId = productData['farmerId'];

            // Get farmer information
            String farmerName = 'Unknown Farmer';
            if (farmerId != null) {
              try {
                final farmerDoc = await _db
                    .collection('farmers')
                    .doc(farmerId)
                    .get();
                if (farmerDoc.exists) {
                  final farmerData = farmerDoc.data();
                  farmerName =
                      farmerData?['name'] ??
                      farmerData?['firstName'] ??
                      'Unknown Farmer';
                }
              } catch (e) {
                print('Error fetching farmer info: $e');
              }
            }

            productsWithFarmers.add({
              'productId': doc.id,
              'farmerName': farmerName,
              'farmerId': farmerId,
              ...productData,
            });
          }

          return productsWithFarmers;
        });
  }
}
