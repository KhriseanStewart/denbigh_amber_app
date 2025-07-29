"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushNotification = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
// Initialize Firebase Admin
admin.initializeApp();
// Listen for new notification requests using v1 API
exports.sendPushNotification = functions.firestore
    .document("notification_requests/{docId}")
    .onCreate(async (snap, _context) => {
    const data = snap.data();
    if (!data || data.processed) {
        console.log("Notification already processed or no data");
        return;
    }
    const { token, title, body, data: notificationData } = data;
    const message = {
        token: token,
        notification: {
            title: title,
            body: body,
        },
        data: notificationData || {},
        android: {
            notification: {
                channelId: "order_notifications",
                priority: "high",
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
    }
    catch (error) {
        console.error("Error sending message:", error);
        // Mark as failed
        await snap.ref.update({
            processed: true,
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
            error: error instanceof Error ? error.message : String(error),
        });
    }
});
//# sourceMappingURL=index.js.map