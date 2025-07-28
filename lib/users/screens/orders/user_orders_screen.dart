import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:denbigh_app/users/database/order_service.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        stream: _orderService.showOrdersForCustomer(userId),
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
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];
    final status = order['status'] ?? 'unknown';
    final totalPrice = (order['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final orderId = order['orderId'] ?? order['id'] ?? '';
    final createdAt = order['createdAt'];
    final receiptImageUrl =
        order['imageUrl'] as String?; // Get receipt image URL

    // Debug: Print order data to see what's available
    print('Order ID: $orderId');
    print('Status: $status');
    print('Has preparationImages: ${order.containsKey('preparationImages')}');
    print('PreparationImages: ${order['preparationImages']}');
    print('---');

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
            // Order header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${orderId.substring(0, 8)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

            // Order items
            ...items.map((item) => _buildOrderItem(item)),

            // Progress indicator for all orders
            SizedBox(height: 12),
            _buildProgressIndicator(status),

            // Preparation images section (if available)
            if (order['preparationImages'] != null &&
                (order['preparationImages'] as List<dynamic>).isNotEmpty) ...[
              SizedBox(height: 12),
              _buildPreparationImagesSection(
                order['preparationImages'] as List<dynamic>,
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
      case 'preparing':
        currentStep = 2;
        break;
      case 'shipped':
        currentStep = 3;
        break;
      case 'completed':
        currentStep = 4;
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
      case 'preparing':
        backgroundColor = Colors.amber[100]!;
        textColor = Colors.amber[800]!;
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

  Widget _buildPreparationImagesSection(List<dynamic> preparationImages) {
    if (preparationImages.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture, size: 20, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'Preparation Photos',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Spacer(),
              Icon(Icons.visibility, size: 16, color: Color(0xFF4CAF50)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'See how your order was prepared by the farmer:',
            style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: preparationImages.length,
              itemBuilder: (context, index) {
                final imageUrl = preparationImages[index] as String;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        _showPreparationImageDialog(imageUrl, index + 1),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF4CAF50), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Color(0xFF4CAF50).withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50),
                                ),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Color(0xFF4CAF50).withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.touch_app, size: 14, color: Color(0xFF4CAF50)),
              SizedBox(width: 4),
              Text(
                'Tap any photo to view full size',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2E7D32),
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

  void _showPreparationImageDialog(String imageUrl, int imageNumber) {
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
                    // Title at the top
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Preparation Photo $imageNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Image
                    Flexible(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            'Failed to load preparation image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
}
