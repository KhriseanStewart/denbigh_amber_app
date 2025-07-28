# Push Notification Setup Guide

## Overview
Your app now uses Firebase Cloud Messaging (FCM) to send push notifications directly to users' phones instead of in-app notifications.

## What's Changed

### 1. Notification Service (lib/utils/services/notification_service.dart)
- Now uses Firebase Cloud Messaging instead of in-app notifications
- Automatically requests notification permissions when initialized
- Saves FCM tokens to user profiles for targeting
- Creates notification requests that are processed by Cloud Functions

### 2. Order Flow
- When a customer places an order, farmers receive push notifications on their phones
- When farmers update order status, customers receive push notifications

### 3. Cloud Functions (functions/index.js)
- Automatically processes notification requests and sends push notifications
- Handles both Android and iOS push notification formatting

## Setup Instructions

### 1. Deploy Cloud Functions
```powershell
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Login to Firebase
firebase login

# Deploy functions
firebase deploy --only functions
```

### 2. Firebase Console Configuration
1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Generate a new Server Key (if not already done)
3. Add your Android package name and iOS bundle ID

### 3. Android Configuration
- Android notification channel is automatically created
- Permissions are added to AndroidManifest.xml
- Firebase messaging service is configured

### 4. iOS Configuration (if needed)
- Add APNs certificates in Firebase Console
- Configure iOS app for push notifications

## How It Works

### Order Placement Flow:
1. Customer places order
2. Order is saved to Firestore
3. `notifyFarmerNewOrder()` is called
4. Notification request is created in `notification_requests` collection
5. Cloud Function detects new request
6. Push notification is sent to farmer's device
7. Farmer sees notification on phone (even when app is closed)

### Order Status Update Flow:
1. Farmer updates order status
2. `notifyCustomerOrderUpdate()` is called
3. Notification request is created
4. Cloud Function sends push notification to customer
5. Customer sees status update on phone

## Notification Features

### For Farmers:
- 🛒 "New Order Received!" with customer name and order value
- Shows customer location and item count
- Includes order details in notification data

### For Customers:
- ✅ Order Confirmed
- 👨‍🍳 Order Being Prepared  
- 🚚 Order Shipped
- 🎉 Order Completed
- ❌ Order Cancelled

## Testing

### Test Push Notifications:
1. Place an order from user app
2. Check farmer's phone for notification (even if app is closed)
3. Update order status from farmer app
4. Check customer's phone for status update notification

### Troubleshooting:
- Check Firebase Functions logs: `firebase functions:log`
- Verify FCM tokens are saved in user documents
- Ensure Cloud Function is deployed successfully
- Check notification permissions are granted on devices

## Files Modified:
- `lib/utils/services/notification_service.dart` - FCM implementation
- `lib/main.dart` - Initialize notification service
- `lib/users/database/order_service.dart` - Added farmer notifications
- `pubspec.yaml` - Added firebase_messaging dependency
- `android/app/src/main/AndroidManifest.xml` - FCM permissions
- `android/app/src/main/kotlin/.../MainActivity.kt` - Notification channel
- `functions/index.js` - Cloud Function for sending notifications
- `functions/package.json` - Function dependencies

## Next Steps:
1. Deploy the Cloud Function: `firebase deploy --only functions`
2. Test order placement and status updates
3. Verify notifications appear on actual devices (not just emulator)
4. Configure iOS push notifications if targeting iOS devices
