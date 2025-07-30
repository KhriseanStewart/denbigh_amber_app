import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denbigh_app/users/database/chat_service.dart';
import 'package:denbigh_app/users/screens/chat_feedback_report/user_chat.dart';
import 'package:denbigh_app/users/screens/dashboard/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final currentUserId = auth!.uid;
  int messageNumber = 0;

  @override
  Widget build(BuildContext context) {
    String formatTimestamp(Timestamp? timestamp) {
      if (timestamp == null) return 'Unknown';

      try {
        DateTime dateTime = timestamp.toDate();
        DateTime now = DateTime.now();

        Duration diff = now.difference(dateTime);

        if (diff.inSeconds < 60) {
          return 'Just now';
        } else if (diff.inMinutes < 60) {
          return '${diff.inMinutes} min ago';
        } else if (diff.inHours < 24) {
          return '${diff.inHours} h ago';
        } else if (diff.inDays < 7) {
          return '${diff.inDays} d ago';
        } else {
          // Format date for older messages
          return DateFormat('MMM dd, yyyy').format(dateTime);
        }
      } catch (e) {
        return 'Invalid date';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Hub"),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 8.0),
        child: StreamBuilder(
          stream: ChatService().getUserChatsStream(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return Center(child: Text("No Data "));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error"));
            }
            final chats = snapshot.data!.docs;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chatData = chats[index].data() as Map<String, dynamic>;
                final participants = List<String>.from(
                  chatData['participants'],
                );

                // Find the other participant
                String otherUserId = participants.firstWhere(
                  (id) => id != currentUserId,
                );

                return FutureBuilder<String>(
                  future: ChatService().getUserName(otherUserId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ListTile(title: Text('Loading...'));
                    }
                    return ListTile(
                      title: Text(snapshot.data ?? ''),
                      subtitle: Text(chatData['lastMessage'] ?? ''),
                      leading: Icon(Icons.person),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (messageNumber > 0)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent.shade100,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(6),
                              child: Text(
                                "$messageNumber",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Text(formatTimestamp(chatData['lastMessageTime'])),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserChat(
                              userId: currentUserId,
                              chatId: chatData['chatId'],
                              recieverId: otherUserId,
                            ),
                          ),
                        );
                        // Navigate to chat screen with chatId
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
