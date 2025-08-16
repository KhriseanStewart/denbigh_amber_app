import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FarmerChatService {
  final db = FirebaseFirestore.instance;
  final uuid = Uuid().v4();

  // Admin ID this allows us to connect tothe admin chat
  static const String adminId = "L235HWCbg2ZJqc3l8KKlvL10HK82";

  Future<String> getFarmerName(String farmerId) async {
    // Check if it's admin first
    if (farmerId == adminId) {
      return 'Admin Support';
    }

    // Try farmers collection - this should be the primary lookup for farmer chat
    DocumentSnapshot farmerDoc = await FirebaseFirestore.instance
        .collection('farmersData')
        .doc(farmerId)
        .get();

    if (farmerDoc.exists && farmerDoc.data() != null) {
      Map<String, dynamic> data = farmerDoc.data() as Map<String, dynamic>;
      return data['farmerName'] ?? 'Unknown Farmer';
    }

    // If no farmer found, return unknown (removed users collection fallback since this is farmer-specific)
    return 'Unknown Farmer';
  }

  Future<void> updateConversation(
    String currentFarmerId,
    String otherFarmerId,
    String message,
  ) async {
    String chatId = getChatId(currentFarmerId, otherFarmerId);

    // Fetch existing userChat document
    final userChatRef = FirebaseFirestore.instance
        .collection('userChats')
        .doc(chatId);
    final userChatSnapshot = await userChatRef.get();

    String otherFarmerName = await getFarmerName(otherFarmerId);

    if (userChatSnapshot.exists) {
      // Update existing document
      await userChatRef.update({
        'participants': [currentFarmerId, otherFarmerId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherFarmerName,
      });
    } else {
      // Create new document
      await userChatRef.set({
        'participants': [currentFarmerId, otherFarmerId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherFarmerName,
      });
    }

    // After sending a message, update userChats for both users
    await _updateUserChat(currentFarmerId, otherFarmerId, message, chatId);
    await _updateUserChat(otherFarmerId, currentFarmerId, message, chatId);
  }

  Future<void> _updateUserChat(
    String farmerId,
    String otherFarmerId,
    String message,
    String chatId,
  ) async {
    final userChatRef = FirebaseFirestore.instance
        .collection('userChats')
        .doc(chatId);

    // Fetch existing document
    final docSnapshot = await userChatRef.get();

    String otherFarmerName = await getFarmerName(otherFarmerId);

    if (docSnapshot.exists) {
      // Update existing
      await userChatRef.update({
        'participants': [farmerId, otherFarmerId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherFarmerName,
        'chatId': chatId,
      });
    } else {
      // Create new
      await userChatRef.set({
        'participants': [farmerId, otherFarmerId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherFarmerName,
        'chatId': chatId,
      });
    }
  }

  Future<void> sendMessage(
    String chatId,
    String senderId,
    String receiverId,
    String message,
  ) async {
    final chatDocRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId);
    final chatSnapshot = await chatDocRef.get();

    final messagesRef = chatDocRef.collection('messages');

    // Add the message to the messages collection
    await messagesRef.add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'chatId': chatId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Check if chat exists
    if (chatSnapshot.exists) {
      // Update existing chat's last message and timestamp
      await chatDocRef.update({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Create a new chat document with initial data
      await chatDocRef.set({
        'farmerId1': senderId,
        'farmerId2': receiverId,
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
        'chatId': chatId,
      });
    }
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  String getChatId(String farmerId1, String farmerId2) {
    List<String> ids = [farmerId1, farmerId2];
    ids.sort();
    return ids.join('_');
  }

  Stream<QuerySnapshot> getFarmerChatsStream(String currentFarmerId) {
    return FirebaseFirestore.instance
        .collection('userChats')
        .where('participants', arrayContains: currentFarmerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Helper method to start a chat with admin
  Future<String> startChatWithAdmin(String farmerId) async {
    return getChatId(farmerId, adminId);
  }
}
