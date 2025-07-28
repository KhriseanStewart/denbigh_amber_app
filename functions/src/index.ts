import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

// Listen for new notification requests using v1 API
export const sendPushNotification = functions.firestore
  .document("notification_requests/{docId}")
  .onCreate(async (
    snap: functions.firestore.DocumentSnapshot,
    _context: functions.EventContext
  ) => {
    const data = snap.data();

    if (!data || data.processed) {
      console.log("Notification already processed or no data");
      return;
    }

    const {token, title, body, data: notificationData} = data;

    const message: admin.messaging.Message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      android: {
        notification: {
          channelId: "order_notifications",
          priority: "high" as const,
          defaultSound: true,
          defaultVibrateTimings: true,
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
            sound: "default",
          },
        },
      },
    };

    try {
      // Send the message
      const response = await admin.messaging().send(message);
      console.log("Successfully sent message:", response);

      // Mark as processed
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        response: response,
      });
    } catch (error) {
      console.error("Error sending message:", error);

      // Mark as failed
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        error: error instanceof Error ? error.message : String(error),
      });
    }
  });
