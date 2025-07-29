import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      print('🔥 Starting FCM initialization...');

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

      print('📱 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print(
          '❌ Notifications not authorized! Status: ${settings.authorizationStatus}',
        );
        return;
      }

      // Get FCM token with better error handling
      await _getAndSaveToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed');
        _saveFCMToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      print('✅ FCM initialization completed');
    } catch (e) {
      print('💥 FCM initialization failed: $e');
    }
  }

  /// Get FCM token and save it with detailed logging
  Future<void> _getAndSaveToken() async {
    try {
      print('🎯 Getting FCM token...');

      String? token;

      // Check if we're on web platform
      if (kIsWeb) {
        print('🌐 Running on web platform');
        try {
          token = await _messaging.getToken();
          print('🌐 Web token result: ${token != null ? "SUCCESS" : "FAILED"}');
        } catch (webError) {
          print('🌐 Web FCM error: $webError');
          token = null;
        }
      } else {
        print('📱 Running on mobile platform');

        // For mobile, try multiple times if needed
        for (int attempt = 1; attempt <= 3; attempt++) {
          try {
            print('📱 Token attempt $attempt/3...');
            token = await _messaging.getToken();

            if (token != null) {
              print('📱 Token SUCCESS on attempt $attempt');
              break;
            } else {
              print('📱 Token was null on attempt $attempt');
              if (attempt < 3) {
                await Future.delayed(Duration(seconds: 2));
              }
            }
          } catch (e) {
            print('📱 Token attempt $attempt failed: $e');
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 2));
            }
          }
        }
      }

      if (token != null) {
        print('🎉 FCM Token received: ${token.substring(0, 30)}...');
        print('📏 Full token length: ${token.length} characters');

        // Save token to Firestore
        await _saveFCMToken(token);
      } else {
        print('❌ Failed to get FCM token after all attempts');

        // Check if Google Play Services are available (Android)
        if (!kIsWeb) {
          print('🔍 Checking device compatibility...');
          // The token being null usually means:
          // 1. Google Play Services not installed/updated
          // 2. Device doesn't support FCM
          // 3. Network issues
          print('💡 Possible issues:');
          print('   - Google Play Services not available');
          print('   - Device in airplane mode');
          print('   - FCM not supported on this device');
        }
      }
    } catch (e) {
      print('💥 Error in _getAndSaveToken: $e');
    }
  }

  /// Save FCM token to user's Firestore document
  Future<void> _saveFCMToken(String token) async {
    try {
      print('💾 Attempting to save FCM token...');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('👤 User authenticated: ${user.uid}');
        print('📝 Saving token to Firestore...');

        await _db.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': kIsWeb ? 'web' : 'mobile',
          'tokenLength': token.length,
        }, SetOptions(merge: true));

        print('✅ FCM token saved successfully to Firestore!');
        print('📄 User document: users/${user.uid}');

        // Verify the token was saved by reading it back
        await _verifyTokenSaved(user.uid, token);
      } else {
        print('❌ User not authenticated - cannot save FCM token');
        print(
          '💡 Make sure user is logged in before initializing notifications',
        );
      }
    } catch (e) {
      print('💥 Error saving FCM token to Firestore: $e');
      print('🔍 This could be a Firestore permissions issue');
    }
  }

  /// Verify that the token was actually saved to Firestore
  Future<void> _verifyTokenSaved(String userId, String expectedToken) async {
    try {
      print('🔍 Verifying token was saved...');

      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        String? savedToken = data?['fcmToken'];

        if (savedToken == expectedToken) {
          print('✅ Token verification successful!');
          print('📱 Saved token: ${savedToken?.substring(0, 30)}...');
        } else {
          print('❌ Token verification failed!');
          print('💡 Expected: ${expectedToken.substring(0, 30)}...');
          print('💡 Found: ${savedToken?.substring(0, 30)}...');
        }
      } else {
        print('❌ User document does not exist!');
        print('💡 Document path: users/$userId');
      }
    } catch (e) {
      print('💥 Error verifying token: $e');
    }
  }

  /// Manually retry getting and saving FCM token (for debugging)
  Future<bool> retryTokenGeneration() async {
    print('🔄 Manual token generation retry...');
    await _getAndSaveToken();

    // Check if we now have a token saved
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        String? token = data?['fcmToken'];
        return token != null;
      }
    }
    return false;
  }

  /// Get current user's FCM token status
  Future<Map<String, dynamic>> getTokenStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        'status': 'error',
        'message': 'User not authenticated',
        'hasToken': false,
      };
    }

    try {
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        return {
          'status': 'error',
          'message': 'User document not found',
          'hasToken': false,
        };
      }

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      String? token = data?['fcmToken'];

      return {
        'status': 'success',
        'hasToken': token != null,
        'tokenPreview': token?.substring(0, 30),
        'lastUpdate': data?['lastTokenUpdate'],
        'platform': data?['platform'],
        'userId': user.uid,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error checking token: $e',
        'hasToken': false,
      };
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
