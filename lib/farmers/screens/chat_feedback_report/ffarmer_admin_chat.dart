import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/farmers/services/ffarmer_chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FarmerChat extends StatefulWidget {
  final String farmerId; // current farmer ID
  final String chatId; // chat ID
  final String receiverId; // other user ID (admin)

  const FarmerChat({
    super.key,
    required this.farmerId,
    required this.chatId,
    required this.receiverId,
  });

  @override
  State<FarmerChat> createState() => _FarmerChatState();
}

class _FarmerChatState extends State<FarmerChat> {
  final TextEditingController messageController = TextEditingController();
  String? otherUserName;
  bool isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserName();
  }

  Future<void> _fetchOtherUserName() async {
    String name = await FarmerChatService().getFarmerName(widget.receiverId);
    setState(() {
      otherUserName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentFarmerId = widget.farmerId;
    final String chatId = widget.chatId;

    return Scaffold(
      backgroundColor: Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          "${otherUserName ?? 'Loading...'} (Admin)",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FarmerChatService().getMessagesStream(chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No messages yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Start a conversation with admin",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      bool isMe = data['senderId'] == currentFarmerId;

                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Color(0xFF4CAF50) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['message'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (data['timestamp'] != null)
                                  Text(
                                    DateFormat(
                                      'hh:mm a',
                                    ).format(data['timestamp'].toDate()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isMe
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: isSendingMessage
                          ? null
                          : () async {
                              if (messageController.text.trim().isEmpty) return;

                              setState(() {
                                isSendingMessage = true;
                              });

                              try {
                                String message = messageController.text.trim();
                                messageController.clear();

                                await FarmerChatService().sendMessage(
                                  chatId,
                                  currentFarmerId,
                                  widget.receiverId,
                                  message,
                                );

                                await FarmerChatService().updateConversation(
                                  currentFarmerId,
                                  widget.receiverId,
                                  message,
                                );
                              } catch (e) {
                                print('Error sending message: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to send message. Please try again.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isSendingMessage = false;
                                });
                              }
                            },
                      icon: Icon(
                        isSendingMessage ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                      ),
                    ),
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
