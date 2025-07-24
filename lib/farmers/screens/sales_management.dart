import 'package:denbigh_app/farmers/model/orders.dart';
import 'package:denbigh_app/farmers/model/orders.dart' as model_orders;
import 'package:denbigh_app/farmers/model/sales.dart';
import 'package:denbigh_app/farmers/services/auth.dart';
import 'package:denbigh_app/farmers/services/sales_order.services.dart';
import 'package:denbigh_app/farmers/widgets/add_receipt_image.dart';
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
    // We'll get the farmer ID in build method from Provider for consistency
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safely get farmer ID with try-catch to handle logout scenarios
    String farmerId = '';
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      farmerId = authService.farmer?.id ?? '';
    } catch (e) {
      print('DEBUG: Error accessing AuthService provider: $e');

      farmerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    }

    print('DEBUG: Sales Management - farmerId from Provider: $farmerId');
    print(
      'DEBUG: Sales Management - farmerId from FirebaseAuth: ${FirebaseAuth.instance.currentUser?.uid}',
    );
    print(
      'DEBUG: Sales Management - Current farmer ID being used for StreamBuilder: $farmerId',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales and Orders Management'),
        centerTitle: true,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              _ExpandableSection(
                title: 'Orders',
                expanded: _ordersExpanded,
                ontap: () => setState(() => _ordersExpanded = !_ordersExpanded),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: farmerId.isEmpty
                      ? Center(child: Text('Please log in to view orders'))
                      : StreamBuilder(
                          stream: SalesAndOrdersService()
                              .getFilteredOrdersForFarmerManual(farmerId),
                          builder: (context, snapshot) {
                            print(
                              'DEBUG: StreamBuilder state - connectionState: ${snapshot.connectionState}',
                            );
                            print(
                              'DEBUG: StreamBuilder state - hasData: ${snapshot.hasData}',
                            );
                            print(
                              'DEBUG: StreamBuilder state - hasError: ${snapshot.hasError}',
                            );
                            if (snapshot.hasError) {
                              print(
                                'DEBUG: StreamBuilder error: ${snapshot.error}',
                              );
                            }
                            if (snapshot.hasData) {
                              print(
                                'DEBUG: StreamBuilder data length: ${snapshot.data?.length}',
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final orders = snapshot.data ?? [];
                            print(
                              'DEBUG: Final orders list length: ${orders.length}',
                            );
                            if (orders.isEmpty) {
                              return Text('No orders yet.');
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                print(
                                  'Order debug: items=${order.items.map((e) => '${e.name},${e.unit},${e.quantity},${e.customerLocation}').toList()}',
                                );
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
                                          'Customer ID: ${order.customerId}',
                                        ),
                                        Text(
                                          'Name: ${(order.items.isNotEmpty && order.items.first.name.isNotEmpty) ? order.items.first.name : 'NO NAME'}',
                                        ),
                                        Text(
                                          'Customer Location: ${(order.items.isNotEmpty && order.items.first.customerLocation.isNotEmpty) ? order.items.first.customerLocation : 'NO LOCATION'}',
                                        ),
                                        Text(
                                          'Quantity: ${(order.items.isNotEmpty && order.items.first.quantity != 0) ? order.items.first.quantity : 'NO QTY'} ${(order.items.isNotEmpty && order.items.first.unit.isNotEmpty) ? order.items.first.unit : 'NO UNIT'}',
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
                                              : 'processing',
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
                                          onChanged: (value) {
                                            if (value != null &&
                                                value != order.status) {
                                              _updateOrderStatus(
                                                order.orderId,
                                                value,
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 8),
                                        if (order.status == "shipped")
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
                  padding: EdgeInsets.all(16.0),
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
                      return StreamBuilder<List<Sale>>(
                        stream: SalesAndOrdersService().getSalesForFarmer(
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
                              final sale = sales[index];
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
                                  title: Text('Sale #${sale.salesId}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Name: ${sale.name}'),
                                      Text('Customer: ${sale.customerName}'),
                                      Text('Customer ID: ${sale.customerId}'),
                                      Text(
                                        'Quantity: ${sale.quantity} ${sale.unit}',
                                      ),
                                      Text(
                                        'Total: \$${sale.totalPrice.toString()}',
                                      ),
                                      Text('Created: ${sale.date.toDate()}'),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: expanded ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: ontap,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
                      child: Icon(
                        expanded ? Icons.remove : Icons.add,
                        key: ValueKey<bool>(expanded),
                        size: 28,
                        color: Theme.of(context).primaryColor,
                        semanticLabel: expanded
                            ? 'Collapse $title'
                            : 'Expand $title',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 600),
              firstChild: child,
              secondChild: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
