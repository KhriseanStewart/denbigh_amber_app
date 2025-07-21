import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/farmers/services/auth.dart';
import 'package:provider/provider.dart';

// This badge shows the LIVE count of processing orders from Firestore
// When new orders come in or are completed, the number updates automatically!
class OrderBadge extends StatelessWidget {
  const OrderBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // If no farmer is logged in, don't show anything
    if (uid == null) {
      return const SizedBox.shrink();
    }

    // Listen to LIVE orders from Firestore for this farmer
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('farmerId', isEqualTo: uid)
          .where('status', isEqualTo: 'processing')
          // Remove the orderId filter to avoid needing a composite index
          .snapshots(),
      builder: (context, snapshot) {
        // Calculate total count of processing orders (not quantity)
        int totalProcessingOrders = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (final doc in snapshot.data!.docs) {
            final orderData = doc.data() as Map<String, dynamic>;

            // Filter out orders without valid orderId in code instead of query
            final orderId = orderData['orderId'] as String? ?? '';
            if (orderId.isEmpty) {
              continue;
            }

            // Count each order as 1 (not by quantity of items)
            totalProcessingOrders += 1;
          }
        }

        // If no processing orders, don't show the badge
        if (totalProcessingOrders == 0) {
          return const SizedBox.shrink();
        }

        // Show the live count in a green badge
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          child: Text(
            '$totalProcessingOrders',
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
