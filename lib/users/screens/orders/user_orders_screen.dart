import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/database/order_service.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            fontFamily: 'Switzer',
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: hexToColor("F4F6F8"),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _orderService.getOrdersWithSalesForCustomer(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your orders will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildFarmerOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildFarmerOrderCard(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];
    final status = order['status'] ?? 'Processing';
    final totalPrice = (order['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final orderId = order['id'] ?? order['orderId'] ?? '';
    final farmerId = order['farmerId'] ?? 'unknown';
    final createdAt = order['createdAt'];
    final hasReceipt = order['hasReceipt'] as bool? ?? false;
    final receiptImageUrl = order['receiptImageUrl'] as String?;

    // Format date
    String formattedDate = 'Unknown date';
    if (createdAt != null) {
      try {
        final date = createdAt.toDate();
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        // Handle date formatting error
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header with farmer info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (hasReceipt) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'COMPLETED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      FutureBuilder<String>(
                        future: _getFarmerName(farmerId),
                        builder: (context, snapshot) {
                          final farmerName = snapshot.data ?? 'Loading...';
                          return Row(
                            children: [
                              Icon(Icons.store, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'From: $farmerName',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Date: $formattedDate',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 12),

            // Order items (multiple products per farmer)
            ...items.map((item) => _buildOrderItem(item)),

            // Progress indicator for this farmer's order
            SizedBox(height: 12),
            _buildProgressIndicator(status),

            // Receipt status indicator
            if (hasReceipt) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt, color: Colors.green[700], size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Receipt Available',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Receipt image section (if available)
            if (receiptImageUrl != null && receiptImageUrl.isNotEmpty) ...[
              SizedBox(height: 12),
              _buildReceiptSection(receiptImageUrl),
            ],

            Divider(),

            // Order total and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (status == 'Processing')
                  TextButton(
                    onPressed: () => _cancelOrder(orderId),
                    child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final name = item['name'] ?? 'Unknown item';
    final quantity = item['quantity'] ?? 0;
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final imageUrl = item['imageUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Item image
          GestureDetector(
            onTap: () {
              if (imageUrl.isNotEmpty) {
                _showImagePreview(imageUrl, name);
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported);
                        },
                      ),
                    )
                  : Icon(Icons.image_not_supported),
            ),
          ),
          SizedBox(width: 12),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  'Qty: $quantity × \$${price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }







  Widget _buildProgressIndicator(String status) {
    // Use the farmer's status list excluding 'Cancelled' for progress tracking
    List<String> steps = statuses.keys
        .where((key) => key != 'Cancelled')
        .toList();
    int currentStep = 0;

    // Normalize status to handle case sensitivity
    String normalizedStatus = status.toLowerCase();

    switch (normalizedStatus) {
      case 'processing':
        currentStep = 0;
        break;
      case 'confirmed':
        currentStep = 1;
        break;
      case 'shipped':
        currentStep = 2;
        break;
      case 'completed':
        currentStep = 3;
        break;
      default:
        currentStep = 0; // Default to processing if unknown status
        break;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: steps.asMap().entries.map((entry) {
              int index = entry.key;
              bool isCompleted = index <= currentStep;
              bool isCurrent = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    //the container with the labeled steps in green
                    // Step circle
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? Colors.green : Colors.grey[300],
                        border: Border.all(
                          color: isCurrent ? Colors.green : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        size: 12,
                        color: isCompleted ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    // Connecting line (except for last step)
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          color: isCompleted ? Colors.green : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 4),

         
          Row(
            children: steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              bool isCurrent = index == currentStep;

              return Expanded(
                child: Text(
                  step,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isCurrent ? Colors.green[800] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'processing':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'confirmed':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'shipped':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case 'completed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReceiptSection(String receiptImageUrl) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 20, color: Colors.green[600]),
              SizedBox(width: 8),
              Text(
                'Receipt Available',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.green[700],
                ),
              ),
              Spacer(),
              Icon(Icons.verified, size: 16, color: Colors.green[600]),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Your order has been processed and a receipt is available.',
            style: TextStyle(fontSize: 12, color: Colors.green[600]),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showReceiptDialog(receiptImageUrl),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  receiptImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.grey),
                          Text(
                            'Failed to load receipt',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.touch_app, size: 14, color: Colors.green[600]),
              SizedBox(width: 4),
              Text(
                'Tap to view full size receipt',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Failed to load receipt',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String imageUrl, String itemName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Item name at the top
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        itemName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Image
                    Flexible(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order'),
        content: Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _orderService.cancelOrder(orderId);
      if (success) {
        displaySnackBar(context, 'Order cancelled successfully');
      } else {
        displaySnackBar(context, 'Failed to cancel order');
      }
    }
  }

  Future<String> _getFarmerName(String farmerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('farmersData')
          .doc(farmerId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Unknown Farmer';
      }
      return 'Unknown Farmer';
    } catch (e) {
      return 'Unknown Farmer';
    }
  }
}
