import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Send notification to farmer when new order is created
  Future<void> notifyFarmerNewOrder({
    required String farmerId,
    required String orderId,
    required String customerName,
    required int totalAmount,
    required int itemCount,
    required String customerLocation,
  }) async {
    try {
      await _db.collection('notifications').add({
        'recipientId': farmerId,
        'type': 'new_order',
        'title': 'New Order Received!',
        'message':
            'You received a new order from $customerName worth \$${totalAmount.toStringAsFixed(2)} ($itemCount items)',
        'data': {
          'orderId': orderId,
          'customerName': customerName,
          'customerLocation': customerLocation,
          'totalAmount': totalAmount,
          'itemCount': itemCount,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  /// Send notification to customer about order status pdates
  Future<void> notifyCustomerOrderUpdate({
    required String customerId,
    required String orderId,
    required String newStatus,
    String? message,
  }) async {
    try {
      String title = 'Order Update';
      String defaultMessage =
          'Your order status has been updated to $newStatus';

      switch (newStatus.toLowerCase()) {
        case 'confirmed':
          title = 'Order Confirmed';
          defaultMessage =
              'Your order has been confirmed and is being prepared';
          break;
        case 'completed':
          title = 'Order Completed';
          defaultMessage = 'Your order has been completed successfully';
          break;
        case 'cancelled':
          title = 'Order Cancelled';
          defaultMessage = 'Your order has been cancelled';
          break;
      }

      await _db.collection('notifications').add({
        'recipientId': customerId,
        'type': 'order_update',
        'title': title,
        'message': message ?? defaultMessage,
        'data': {'orderId': orderId, 'status': newStatus},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  /// Get notifications for a specific user
  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _db.batch();
      final snapshot = await _db
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {}
  }

  /// Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
