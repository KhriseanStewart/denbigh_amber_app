# 📱 Complete Firebase Push Notification Installation Guide

## 🎯 **Overview**
This guide will help you install the exact Firebase Cloud Messaging push notification system from the **Denbigh Amber App** into any other Flutter application. The system sends real phone notifications (not in-app) using Firebase Cloud Functions.

---

## 📋 **Prerequisites**

### **Required Tools:**
- Flutter SDK (3.0+)
- Firebase CLI (`npm install -g firebase-tools`)
- Node.js (18+) for Firebase Functions
- VS Code or Android Studio
- Physical device for testing (push notifications don't work on emulators)

### **Required Accounts:**
- Firebase account with Blaze plan (for Cloud Functions)
- Google Cloud Console access
- Apple Developer account (for iOS push notifications)

---

## 🏗️ **PART 1: Firebase Project Setup**

### **Step 1: Create Firebase Project**
```bash
# 1. Go to https://console.firebase.google.com
# 2. Click "Create a project"
# 3. Enter project name (e.g., "my-app-notifications")
# 4. Enable Google Analytics (optional)
# 5. Choose or create Analytics account
# 6. Click "Create project"
```

### **Step 2: Enable Required Services**
```bash
# In Firebase Console:
# 1. Go to "Build" → "Authentication" → "Get started"
# 2. Go to "Build" → "Firestore Database" → "Create database"
#    - Choose "Start in test mode" for development
#    - Select nearest region
# 3. Go to "Build" → "Functions" → "Get started"
# 4. Go to "Project Settings" → "Cloud Messaging" → Note your "Sender ID"
```

### **Step 3: Upgrade to Blaze Plan**
```bash
# In Firebase Console:
# 1. Go to "Usage and billing" → "Details & settings"
# 2. Click "Modify plan"
# 3. Select "Blaze - Pay as you go"
# 4. Add payment method
# Note: Required for Cloud Functions external API calls
```

---

## 📱 **PART 2: Flutter App Configuration**

### **Step 4: Install Flutter Dependencies**
```yaml
# Add to pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  firebase_messaging: ^14.7.10
  cloud_firestore: ^4.14.0
  flutter_local_notifications: ^17.0.0

dev_dependencies:
  flutter_lints: ^3.0.0
```

```bash
# Install dependencies
flutter pub get
```

### **Step 5: Add Firebase Configuration Files**

#### **Android Setup:**
```bash
# 1. In Firebase Console → Project Settings → General
# 2. Click "Add app" → Android
# 3. Enter Android package name (from android/app/build.gradle)
# 4. Download google-services.json
# 5. Place in: android/app/google-services.json
```

```gradle
// android/build.gradle (project level)
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

```gradle
// android/app/build.gradle
plugins {
    id 'com.google.gms.google-services'
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}

android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### **iOS Setup:**
```bash
# 1. In Firebase Console → Project Settings → General
# 2. Click "Add app" → iOS
# 3. Enter iOS bundle ID (from ios/Runner.xcodeproj)
# 4. Download GoogleService-Info.plist
# 5. Add to ios/Runner/ using Xcode (not Finder!)
```

---

## 🔧 **PART 3: Copy Core Notification Files**

### **Step 6: Create Notification Service**
Create: `lib/utils/services/notification_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  // Initialize FCM and local notifications
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);

    // Configure FCM
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Get and save FCM token
  static Future<void> saveTokenToDatabase() async {
    String? token = await _messaging.getToken();
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (token != null && userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
      print('FCM Token saved: $token');
    }
  }

  // Send notification to specific user
  static Future<void> sendNotificationToUser({
    required String recipientUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create notification request document
      await FirebaseFirestore.instance
          .collection('notification_requests')
          .add({
        'recipientUserId': recipientUserId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
      });
      
      print('Notification request created successfully');
    } catch (e) {
      print('Error creating notification request: $e');
    }
  }

  // Example: Notify farmer about new order
  static Future<void> notifyFarmerNewOrder({
    required String farmerId,
    required String orderId,
    required String customerName,
  }) async {
    await sendNotificationToUser(
      recipientUserId: farmerId,
      title: 'New Order Received!',
      body: 'You have a new order from $customerName',
      data: {
        'type': 'new_order',
        'orderId': orderId,
        'customerId': FirebaseAuth.instance.currentUser?.uid,
      },
    );
  }

  // Example: Notify customer about order update
  static Future<void> notifyCustomerOrderUpdate({
    required String customerId,
    required String orderId,
    required String status,
  }) async {
    await sendNotificationToUser(
      recipientUserId: customerId,
      title: 'Order Update',
      body: 'Your order #$orderId is now $status',
      data: {
        'type': 'order_update',
        'orderId': orderId,
        'status': status,
      },
    );
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Handling a foreground message: ${message.messageId}');
    
    // Show local notification
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Handle notification tap when app is in background
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('Message clicked: ${message.data}');
    // Handle navigation based on message.data
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
```

### **Step 7: Initialize in main.dart**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils/services/notification_service.dart';
// Import your firebase_options.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  await NotificationService.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Save FCM token when user signs in
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    // Wait for user authentication
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        NotificationService.saveTokenToDatabase();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      home: YourHomeScreen(),
    );
  }
}
```

---

## ⚡ **PART 4: Firebase Cloud Functions Setup**

### **Step 8: Initialize Firebase Functions**
```bash
# In your project root directory
firebase login
firebase init functions

# Choose:
# - Use an existing project (select your Firebase project)
# - Language: TypeScript
# - Use ESLint: Yes
# - Install dependencies: Yes
```

### **Step 9: Configure Firebase Functions**
Edit `functions/package.json`:
```json
{
  "name": "functions",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "start": "npm run serve",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.0.0",
    "typescript": "^5.0.0"
  },
  "private": true
}
```

### **Step 10: Create Cloud Function**
Edit `functions/src/index.ts`:
```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Cloud Function to send push notifications
export const sendPushNotification = functions.firestore
  .document('notification_requests/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    if (!data || data.processed) {
      return null;
    }

    try {
      // Get recipient's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(data.recipientUserId)
        .get();

      if (!userDoc.exists) {
        console.error('User not found:', data.recipientUserId);
        return null;
      }

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        console.error('FCM token not found for user:', data.recipientUserId);
        return null;
      }

      // Prepare notification message
      const message = {
        notification: {
          title: data.title,
          body: data.body,
        },
        data: data.data || {},
        token: fcmToken,
      };

      // Send notification
      const response = await admin.messaging().send(message);
      console.log('Successfully sent message:', response);

      // Mark as processed
      await snap.ref.update({ processed: true, sentAt: admin.firestore.FieldValue.serverTimestamp() });

      return response;
    } catch (error) {
      console.error('Error sending message:', error);
      
      // Mark as failed
      await snap.ref.update({ 
        processed: true, 
        error: error.message, 
        failedAt: admin.firestore.FieldValue.serverTimestamp() 
      });
      
      return null;
    }
  });
```

### **Step 11: Deploy Cloud Function**
```bash
# In functions directory
cd functions
npm install

# Deploy
firebase deploy --only functions

# Verify deployment
firebase functions:log
```

---

## 📱 **PART 5: Platform-Specific Configuration**

### **Step 12: Android Permissions**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <application>
        <!-- Notification icon -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
        
        <!-- Notification channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="default_channel" />
    </application>
</manifest>
```

### **Step 13: iOS Configuration**
Add to `ios/Runner/Info.plist`:
```xml
<dict>
    <!-- Existing keys -->
    
    <!-- Push notifications capability -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
    
    <!-- Firebase messaging -->
    <key>FirebaseMessagingAutoInitEnabled</key>
    <true/>
</dict>
```

Enable push notifications in Xcode:
```
1. Open ios/Runner.xcworkspace in Xcode
2. Select Runner → Signing & Capabilities
3. Click "+ Capability"
4. Add "Push Notifications"
5. Add "Background Modes" → Check "Remote notifications"
```

---

## 🧪 **PART 6: Testing and Implementation**

### **Step 14: Test Basic Setup**
```dart
// Add to any screen where you want to test
class TestNotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Notifications')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Test sending notification to current user
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  await NotificationService.sendNotificationToUser(
                    recipientUserId: currentUser.uid,
                    title: 'Test Notification',
                    body: 'This is a test notification!',
                    data: {'test': 'true'},
                  );
                }
              },
              child: Text('Send Test Notification'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await NotificationService.saveTokenToDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Token saved!')),
                );
              },
              child: Text('Save FCM Token'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **Step 15: Implement in Your App Logic**
```dart
// Example: In your order creation logic
Future<void> createOrder({
  required String farmerId,
  required Map<String, dynamic> orderData,
}) async {
  try {
    // Create order in Firestore
    DocumentReference orderRef = await FirebaseFirestore.instance
        .collection('orders')
        .add(orderData);

    // Send notification to farmer
    await NotificationService.notifyFarmerNewOrder(
      farmerId: farmerId,
      orderId: orderRef.id,
      customerName: orderData['customerName'] ?? 'A customer',
    );

    print('Order created and notification sent!');
  } catch (e) {
    print('Error creating order: $e');
  }
}

// Example: In your order status update logic
Future<void> updateOrderStatus({
  required String orderId,
  required String customerId,
  required String newStatus,
}) async {
  try {
    // Update order in Firestore
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});

    // Send notification to customer
    await NotificationService.notifyCustomerOrderUpdate(
      customerId: customerId,
      orderId: orderId,
      status: newStatus,
    );

    print('Order updated and notification sent!');
  } catch (e) {
    print('Error updating order: $e');
  }
}
```

---

## 🔧 **PART 7: Advanced Configuration**

### **Step 16: Firestore Security Rules**
Add to Firebase Console → Firestore → Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Only authenticated users can create notification requests
    match /notification_requests/{docId} {
      allow create: if request.auth != null;
      allow read, update: if false; // Only Cloud Functions should modify
    }
    
    // Add other collection rules as needed
  }
}
```

### **Step 17: Error Handling and Logging**
```dart
class NotificationService {
  // Enhanced error handling
  static Future<void> sendNotificationToUser({
    required String recipientUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('notification_requests')
          .add({
        'recipientUserId': recipientUserId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
        'senderId': FirebaseAuth.instance.currentUser?.uid,
      });
      
      print('✅ Notification request created successfully');
    } catch (e) {
      print('❌ Error creating notification request: $e');
      
      // Optional: Log to analytics or error reporting service
      // FirebaseCrashlytics.instance.recordError(e, null);
    }
  }
}
```

---

## 🚀 **PART 8: Deployment Checklist**

### **Production Setup:**
- [ ] Upgrade to Firebase Blaze plan
- [ ] Configure proper Firestore security rules
- [ ] Set up Firebase App Check (optional security)
- [ ] Configure notification icons and channels
- [ ] Test on physical devices (iOS & Android)
- [ ] Set up APNs certificates for iOS production
- [ ] Configure build variants for debug/release
- [ ] Set up monitoring and analytics

### **Testing Checklist:**
- [ ] Foreground notifications work
- [ ] Background notifications work
- [ ] App terminated notifications work
- [ ] Notification tapping opens correct screen
- [ ] FCM tokens are saved correctly
- [ ] Cloud Function deploys successfully
- [ ] Firestore rules allow necessary operations
- [ ] Error handling works for invalid tokens

---

## 🆘 **Common Issues & Solutions**

### **Issue: Notifications not received**
**Solutions:**
1. Check FCM token is saved to Firestore
2. Verify Cloud Function is deployed
3. Check Firestore security rules
4. Ensure device has internet connection
5. Test on physical device (not emulator)

### **Issue: Cloud Function deployment fails**
**Solutions:**
1. Ensure Firebase project has Blaze plan
2. Check Node.js version (use 18+)
3. Verify firebase-tools is latest version
4. Run `firebase login` and re-authenticate

### **Issue: iOS notifications not working**
**Solutions:**
1. Add GoogleService-Info.plist to Xcode (not Finder)
2. Enable Push Notifications capability in Xcode
3. Configure APNs certificates in Firebase Console
4. Test on physical iOS device

---

## 📞 **Support**

If you encounter issues:
1. Check Firebase Console logs
2. Run `firebase functions:log` for Cloud Function errors
3. Check device logs for FCM token issues
4. Verify all configuration files are in correct locations

---

## ✅ **Final Verification**

Your notification system is successfully installed when:
1. ✅ FCM tokens are saved to user documents
2. ✅ notification_requests collection creates documents
3. ✅ Cloud Function processes requests (check logs)
4. ✅ Physical devices receive notifications
5. ✅ Tapping notifications opens your app

**🎉 Congratulations! Your Firebase push notification system is now ready!**
