import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final db = FirebaseFirestore.instance;
  final uuid = Uuid().v4();

  Future<String> getUserName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      return data['name'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  Future<void> updateConversation(
    String currentUserId,
    String otherUserId,
    String message,
  ) async {
    String chatId = getChatId(currentUserId, otherUserId);

    // Fetch existing userChat document
    final userChatRef = FirebaseFirestore.instance
        .collection('userChats')
        .doc(chatId);
    final userChatSnapshot = await userChatRef.get();

    String otherUserName = await getUserName(otherUserId);

    if (userChatSnapshot.exists) {
      // Update existing document
      await userChatRef.update({
        'participants': [currentUserId, otherUserId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherUserName,
      });
    } else {
      // Create new document
      await userChatRef.set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherUserName,
      });
    }

    // After sending a message, update userChats for both users
    await _updateUserChat(currentUserId, otherUserId, message, chatId);
    await _updateUserChat(otherUserId, currentUserId, message, chatId);
  }

  Future<void> _updateUserChat(
    String userId,
    String otherUserId,
    String message,
    String chatId,
  ) async {
    final userChatRef = FirebaseFirestore.instance
        .collection('userChats')
        .doc(chatId);

    // Fetch existing document
    final docSnapshot = await userChatRef.get();

    String otherUserName = await getUserName(otherUserId);

    if (docSnapshot.exists) {
      // Update existing
      await userChatRef.update({
        'participants': [userId, otherUserId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherUserName,
        'chatId': chatId,
      });
    } else {
      // Create new
      await userChatRef.set({
        'participants': [userId, otherUserId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'userName': otherUserName,
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
        'userId1': senderId, // optional: store info about users
        'userId2': receiverId,
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
        'chatId': chatId,
        // add other initial fields if needed
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

  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Stream<QuerySnapshot> getUserChatsStream(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('userChats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
