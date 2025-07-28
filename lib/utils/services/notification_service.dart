import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token and save to user profile
    String? token = await _messaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveFCMToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Save FCM token to user's Firestore document
  Future<void> _saveFCMToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Handle foreground messages (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.notification?.title}');
    // You can show an in-app notification here if needed
  }

  /// Send push notification to farmer when new order is created
  Future<void> notifyFarmerNewOrder({
    required String farmerId,
    required String orderId,
    required String customerName,
    required int totalAmount,
    required int itemCount,
    required String customerLocation,
  }) async {
    try {
      // Get farmer's FCM token
      String? fcmToken = await _getFCMToken(farmerId);
      if (fcmToken == null) {
        print('No FCM token found for farmer: $farmerId');
        return;
      }

      // Send push notification
      await _sendPushNotification(
        token: fcmToken,
        title: 'New Order Received! 🛒',
        body:
            'You received a new order from $customerName worth \$${totalAmount.toStringAsFixed(2)} ($itemCount items)',
        data: {
          'type': 'new_order',
          'orderId': orderId,
          'customerName': customerName,
          'customerLocation': customerLocation,
          'totalAmount': totalAmount.toString(),
          'itemCount': itemCount.toString(),
        },
      );

      print('Push notification sent to farmer: $farmerId');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  /// Send push notification to customer about order status updates
  Future<void> notifyCustomerOrderUpdate({
    required String customerId,
    required String orderId,
    required String newStatus,
    String? message,
  }) async {
    try {
      // Get customer's FCM token
      String? fcmToken = await _getFCMToken(customerId);
      if (fcmToken == null) {
        print('No FCM token found for customer: $customerId');
        return;
      }

      String title = 'Order Update';
      String defaultMessage =
          'Your order status has been updated to $newStatus';
      String emoji = '📦';

      switch (newStatus.toLowerCase()) {
        case 'confirmed':
          title = 'Order Confirmed';
          defaultMessage =
              'Your order has been confirmed and is being prepared';
          emoji = '✅';
          break;
        case 'preparing':
          title = 'Order Being Prepared';
          defaultMessage = 'Your order is now being prepared';
          emoji = '👨‍🍳';
          break;
        case 'shipped':
          title = 'Order Shipped';
          defaultMessage = 'Your order has been shipped and is on the way';
          emoji = '🚚';
          break;
        case 'completed':
          title = 'Order Completed';
          defaultMessage = 'Your order has been completed successfully';
          emoji = '🎉';
          break;
        case 'cancelled':
          title = 'Order Cancelled';
          defaultMessage = 'Your order has been cancelled';
          emoji = '❌';
          break;
      }

      // Send push notification
      await _sendPushNotification(
        token: fcmToken,
        title: '$title $emoji',
        body: message ?? defaultMessage,
        data: {'type': 'order_update', 'orderId': orderId, 'status': newStatus},
      );

      print('Push notification sent to customer: $customerId');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  /// Get FCM token for a specific user
  Future<String?> _getFCMToken(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['fcmToken'] as String?;
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
    return null;
  }

  /// Send push notification using FCM
  Future<void> _sendPushNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // For sending push notifications, you'll need to use Firebase Functions
      // or a server-side implementation. FCM client SDK can't send notifications directly.
      // For now, we'll store the notification request and use a server trigger

      await _db.collection('notification_requests').add({
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      print('Notification request created - will be processed by server');
    } catch (e) {
      print('Error creating notification request: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.notification?.title}');
}
