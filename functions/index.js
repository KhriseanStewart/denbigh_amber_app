const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");
const {getFirestore} = require("firebase-admin/firestore");

// Initialize Firebase Admin
initializeApp();

// Listen for new notification requests
exports.sendPushNotification = onDocumentCreated("notification_requests/{docId}", async (event) => {
  const data = event.data.data();
  
  if (data.processed) {
    console.log("Notification already processed");
    return;
  }

  const {token, title, body, data: notificationData} = data;

  const message = {
    token: token,
    notification: {
      title: title,
      body: body,
    },
    data: notificationData || {},
    android: {
      notification: {
        channelId: 'order_notifications',
        priority: 'high',
        defaultSound: true,
        defaultVibrateTimings: true,
        icon: 'ic_notification',
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {
            title: title,
            body: body,
          },
          badge: 1,
          sound: 'default',
        },
      },
    },
  };

  try {
    // Send the message
    const response = await getMessaging().send(message);
    console.log('Successfully sent message:', response);

    // Mark as processed
    await getFirestore()
      .collection('notification_requests')
      .doc(event.params.docId)
      .update({
        processed: true,
        processedAt: new Date(),
        response: response,
      });

  } catch (error) {
    console.error('Error sending message:', error);
    
    // Mark as failed
    await getFirestore()
      .collection('notification_requests')
      .doc(event.params.docId)
      .update({
        processed: true,
        processedAt: new Date(),
        error: error.message,
      });
  }
});
