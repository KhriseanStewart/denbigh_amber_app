import 'package:denbigh_app/farmers/model/sales.dart';
import 'package:denbigh_app/farmers/services/auth.dart';
import 'package:denbigh_app/farmers/services/sales_order.services.dart';
import 'package:denbigh_app/farmers/widgets/add_receipt_image.dart';
import 'package:denbigh_app/farmers/widgets/add_preparation_images.dart';
import 'package:denbigh_app/farmers/widgets/used_list/list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesManagementPage extends StatefulWidget {
  const SalesManagementPage({super.key});

  @override
  State<SalesManagementPage> createState() => _SalesManagementPageState();
}

class _SalesManagementPageState extends State<SalesManagementPage> {
  bool _ordersExpanded = false;
  bool _salesExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final farmerId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (farmerId.isEmpty) {
        return;
      }

      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        return;
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final orderFarmerId = orderData['farmerId'] ?? '';

      // Only allow farmer to update their own orders
      if (orderFarmerId != farmerId) {
        return;
      }

      // Update the order status
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': newStatus},
      );
    } catch (e) {
      // Don't throw the error to prevent app crashes
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get farmer ID with try-catch to handle logout scenarios
    String farmerId = '';
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      farmerId = authService.farmer?.id ?? '';
    } catch (e) {
      farmerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          'Sales & Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, size: 28, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Sales Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage your orders and track sales performance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              _ExpandableSection(
                title: 'Orders',
                expanded: _ordersExpanded,
                ontap: () => setState(() => _ordersExpanded = !_ordersExpanded),
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: farmerId.isEmpty
                      ? Center(child: Text('Please log in to view orders'))
                      : StreamBuilder(
                          stream: SalesAndOrdersService()
                              .getFilteredOrdersForFarmerManual(farmerId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final orders = snapshot.data ?? [];
                            if (orders.isEmpty) {
                              return Text('No orders yet.');
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.teal[50],
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Text(
                                      'Order #:${order.orderId.substring(0, 6)}',
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Customer: ${order.customerName}'),
                                        Text(
                                          'Customer ID: ${order.customerId.substring(0, 6)}',
                                        ),
                                        // Display all items in the order with numbering
                                        ...order.items.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key + 1;
                                          final item = entry.value;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${index}.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${item.name} - Qty: ${item.quantity} ${item.unit}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        SizedBox(height: 4),
                                        Text(
                                          'Customer Location: ${(order.items.isNotEmpty && order.items.first.customerLocation.isNotEmpty) ? order.items.first.customerLocation : 'NO LOCATION'}',
                                        ),
                                        Text(
                                          'Total: \$${order.totalPrice.toString()}',
                                        ),
                                        Text(
                                          'Created: ${order.createdAt.toString().split('.')[0]}',
                                        ),
                                        DropdownButton<String>(
                                          value:
                                              statuses.keys.contains(
                                                order.status,
                                              )
                                              ? order.status
                                              : 'Processing',
                                          items: statuses.keys
                                              .map(
                                                (
                                                  status,
                                                ) => DropdownMenuItem<String>(
                                                  value: status,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        color: statuses[status],
                                                        size: 12,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        status[0]
                                                                .toUpperCase() +
                                                            status.substring(1),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (value) async {
                                            if (value != null &&
                                                value != order.status) {
                                              // Enforce sequential status flow: Processing → Confirmed → Preparing → Shipped
                                              bool canChangeStatus = false;
                                              String errorMessage = '';

                                              switch (order.status
                                                  .toLowerCase()) {
                                                case 'processing':
                                                  // From Processing, can only go to Confirmed or Cancelled
                                                  canChangeStatus =
                                                      value == 'Confirmed' ||
                                                      value == 'Cancelled';
                                                  if (!canChangeStatus) {
                                                    errorMessage =
                                                        'Orders must be Confirmed first before proceeding to other stages.';
                                                  }
                                                  break;
                                                case 'confirmed':
                                                  // From Confirmed, can only go to Preparing or Cancelled
                                                  canChangeStatus =
                                                      value == 'Preparing' ||
                                                      value == 'Cancelled';
                                                  if (!canChangeStatus) {
                                                    errorMessage =
                                                        'Orders must be set to Preparing before shipping.';
                                                  }
                                                  break;
                                                case 'preparing':
                                                  // From Preparing, can only go to Shipped or Cancelled
                                                  canChangeStatus =
                                                      value == 'Shipped' ||
                                                      value == 'Cancelled';
                                                  if (!canChangeStatus) {
                                                    errorMessage =
                                                        'Orders can only be marked as Shipped after preparation.';
                                                  }
                                                  break;
                                                case 'shipped':
                                                  // From Shipped, can only go to Completed
                                                  canChangeStatus =
                                                      value == 'Completed';
                                                  if (!canChangeStatus) {
                                                    errorMessage =
                                                        'Shipped orders can only be marked as Completed.';
                                                  }
                                                  break;
                                                default:
                                                  // For Completed or Cancelled, no further changes allowed except Cancelled can be set from any state
                                                  canChangeStatus =
                                                      value == 'Cancelled';
                                                  if (!canChangeStatus) {
                                                    errorMessage =
                                                        'This order status cannot be changed further.';
                                                  }
                                                  break;
                                              }

                                              if (!canChangeStatus) {
                                                // Show error dialog
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.warning,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Invalid Status Change',
                                                          ),
                                                        ],
                                                      ),
                                                      content: Text(
                                                        errorMessage,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                          child: Text(
                                                            'OK',
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xFF4CAF50,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                return; // Don't proceed with status change
                                              }

                                              // Proceed with allowed status changes
                                              if (value == 'Preparing') {
                                                // Navigate to preparation images screen
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddPreparationImages(
                                                          orderId:
                                                              order.orderId,
                                                          onImagesUploaded: (urls) {
                                                            // The status is updated in the AddPreparationImages widget
                                                          },
                                                        ),
                                                  ),
                                                );
                                              } else {
                                                _updateOrderStatus(
                                                  order.orderId,
                                                  value,
                                                );
                                              }
                                            }
                                          },
                                        ),
                                        SizedBox(height: 8),
                                        if (order.status == "Shipped")
                                          Center(
                                            child: TextButton.icon(
                                              icon: Icon(
                                                Icons.receipt_long,
                                                size: 32,
                                                color: Colors.green.shade700,
                                              ),
                                              label: Text('Add Receipt'),
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (_) => Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: MediaQuery.of(
                                                        context,
                                                      ).viewInsets.bottom,
                                                      top: 24,
                                                      left: 12,
                                                      right: 12,
                                                    ),
                                                    child: AddReceiptImage(
                                                      orderId: order.orderId,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    trailing: Icon(Icons.chevron_right),
                                    onTap: () {},
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
              SizedBox(height: 24),
              _ExpandableSection(
                title: 'Sales',
                expanded: _salesExpanded,
                ontap: () => setState(() => _salesExpanded = !_salesExpanded),
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: FutureBuilder<User?>(
                    future: FirebaseAuth.instance.authStateChanges().first,
                    builder: (context, userSnap) {
                      if (userSnap.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (userSnap.hasError) {
                        return Center(child: Text('Error: ${userSnap.error}'));
                      }
                      if (!userSnap.hasData) {
                        return Center(
                          child: Text('Please log in to see sales.'),
                        );
                      }
                      final farmerId = userSnap.data!.uid;
                      return StreamBuilder<List<SalesGroup>>(
                        stream: SalesAndOrdersService().getMultiSalesForFarmer(
                          farmerId,
                        ),
                        builder: (context, saleSnap) {
                          if (saleSnap.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (saleSnap.hasError) {
                            return Center(
                              child: Text('Error: ${saleSnap.error}'),
                            );
                          }
                          final sales = saleSnap.data ?? [];
                          if (sales.isEmpty) {
                            return Text('No sales yet.');
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: sales.length,
                            itemBuilder: (context, index) {
                              final saleGroup = sales[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.orange[50],
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text('Sale #${saleGroup.sessionId}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Customer: ${saleGroup.customerName}',
                                      ),
                                      Text(
                                        'Customer ID: ${saleGroup.customerId.substring(0, 6)}',
                                      ),
                                      Text(
                                        'Customer Location: ${saleGroup.customerLocation.isNotEmpty ? saleGroup.customerLocation : 'NO LOCATION'}',
                                      ),
                                      // Display all items in the sale group with numbering
                                      ...saleGroup.items.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key + 1;
                                        final item = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${index}.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${item.name} - Qty: ${item.quantity} ${item.unit}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      SizedBox(height: 4),
                                      Text(
                                        'Total: \$${saleGroup.totalPrice.toString()}',
                                      ),
                                      Text(
                                        'Created: ${saleGroup.date.toDate().toString().split('.')[0]}',
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () {},
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback ontap;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    required this.expanded,
    required this.ontap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(expanded ? 0.15 : 0.05),
            spreadRadius: 0,
            blurRadius: expanded ? 15 : 8,
            offset: Offset(0, expanded ? 6 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: ontap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: expanded
                      ? [Color(0xFFF1F8E9), Color(0xFFE8F5E8)]
                      : [Colors.white, Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
                      child: Icon(
                        expanded ? Icons.remove : Icons.add,
                        key: ValueKey<bool>(expanded),
                        size: 24,
                        color: Color(0xFF4CAF50),
                        semanticLabel: expanded
                            ? 'Collapse $title'
                            : 'Expand $title',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  Icon(
                    title.toLowerCase().contains('order')
                        ? Icons.shopping_bag
                        : Icons.analytics,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 600),
            firstChild: Container(padding: EdgeInsets.all(16), child: child),
            secondChild: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
