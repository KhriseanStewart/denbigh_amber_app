import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/src/users/database/chat_service.dart';
import 'package:denbigh_app/src/users/screens/dashboard/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserChat extends StatefulWidget {
  final String userId; // current user ID
  final String chatId; // chat ID
  final String recieverId; // other user ID

  const UserChat({
    super.key,
    required this.userId,
    required this.chatId,
    required this.recieverId,
  });

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  final TextEditingController messageController = TextEditingController();
  String? otherUserName;
  bool isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserName();
  }

  Future<void> _fetchOtherUserName() async {
    String name = await ChatService().getUserName(widget.recieverId);
    setState(() {
      otherUserName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = auth!.uid;
    final String chatId = widget.chatId;
    return Scaffold(
      appBar: AppBar(title: Text("${otherUserName ?? 'Loading...'} (Admin)")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ChatService().getMessagesStream(chatId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[messages.length - 1 - index];
                      final data = msg.data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == currentUserId;

                      return ListTile(
                        title: Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.green[100]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(data['message']),
                          ),
                        ),
                        subtitle: Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: data['timestamp'] != null
                              ? Text(
                                  DateFormat(
                                    'hh:mm a',
                                  ).format(data['timestamp'].toDate()),
                                  style: TextStyle(fontSize: 10),
                                )
                              : CircularProgressIndicator(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: isSendingMessage
                        ? CircularProgressIndicator()
                        : Icon(Icons.send, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: () async {
                      final message = messageController.text.trim();
                      if (message.isNotEmpty) {
                        messageController.clear();
                        await ChatService().sendMessage(
                          chatId,
                          currentUserId,
                          widget.recieverId,
                          message,
                        );
                        await ChatService().updateConversation(
                          currentUserId,
                          widget.recieverId,
                          message,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
