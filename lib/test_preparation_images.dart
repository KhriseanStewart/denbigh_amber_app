import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestPreparationImages extends StatelessWidget {
  const TestPreparationImages({super.key});

  Future<void> _addTestPreparationImages() async {
    try {
      // Get the first order in the database
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .limit(1)
          .get();

      if (ordersSnapshot.docs.isNotEmpty) {
        final orderDoc = ordersSnapshot.docs.first;
        final orderId = orderDoc.id;

        // Add test preparation images
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
              'preparationImages': [
                'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Prep+1',
                'https://via.placeholder.com/300x300/66BB6A/FFFFFF?text=Prep+2',
                'https://via.placeholder.com/300x300/2E7D32/FFFFFF?text=Prep+3',
              ],
              'status': 'Preparing',
              'preparationTimestamp': FieldValue.serverTimestamp(),
            });

        print('✅ Test preparation images added to order: $orderId');
      } else {
        print('❌ No orders found in database');
      }
    } catch (e) {
      print('❌ Error adding test preparation images: $e');
    }
  }

  Future<void> _viewOrders() async {
    try {
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      print('📋 Found ${ordersSnapshot.docs.length} orders:');
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        print('Order ${doc.id}:');
        print('  Status: ${data['status']}');
        print('  Customer: ${data['customerId']}');
        print('  Prep Images: ${data['preparationImages'] ?? 'None'}');
        print('---');
      }
    } catch (e) {
      print('❌ Error viewing orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Preparation Images'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Preparation Images Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _addTestPreparationImages,
              child: Text('Add Test Preparation Images'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF66BB6A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _viewOrders,
              child: Text('View All Orders (Check Console)'),
            ),
            SizedBox(height: 20),
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 10),
            Text(
              '1. Tap "Add Test Preparation Images" to add sample images to the first order\n'
              '2. Go to User Orders screen to see the preparation images\n'
              '3. Check the console output for debugging info',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
