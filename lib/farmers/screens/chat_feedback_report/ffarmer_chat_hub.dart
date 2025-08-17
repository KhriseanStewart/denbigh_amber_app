import 'package:denbigh_app/farmers/services/auth.dart';
import 'package:denbigh_app/farmers/services/ffarmer_chat_service.dart';
import 'package:denbigh_app/farmers/screens/chat_feedback_report/ffarmer_admin_chat.dart';
import 'package:denbigh_app/farmers/screens/chat_feedback_report/ffarmer_feedback.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHub extends StatefulWidget {
  const ChatHub({super.key});

  @override
  State<ChatHub> createState() => _ChatHubState();
}

class _ChatHubState extends State<ChatHub> {
  final AuthService _authService = AuthService();
  String? chatId;

  @override
  void initState() {
    super.initState();
    getChatId();
  }

  void getChatId() async {
    final farmer = _authService.farmer;
    if (farmer != null) {
      final id = await FarmerChatService().getChatId(
        farmer.id,
        FarmerChatService.adminId,
      );
      setState(() {
        chatId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer = _authService.farmer;

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Chat Hub")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text("Please log in to access chat"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    if (chatId == null) {
      // Show a loading indicator while fetching chatId
      return Scaffold(
        backgroundColor: Color(0xFFF8FBF8),
        appBar: AppBar(
          title: Text(
            "Farmer Chat Hub",
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
                colors: [
                  Color(0xFF66BB6A),
                  Color(0xFF4CAF50),
                  Color(0xFF2E7D32),
                ],
              ),
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          "Farmer Chat Hub",
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
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("Leave a Feedback"),
              leading: Icon(Icons.feedback_outlined),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              subtitle: Text(
                "This app is still in development, leave a feedback for any errors. Thank you for testing!",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
                );
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text("Contact Admin Support"),
              leading: Icon(Icons.admin_panel_settings),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              subtitle: Text(
                "Get help with your account, products, sales, or report any issues to admin support",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmerChat(
                      farmerId: farmer.id,
                      chatId: chatId!,
                      receiverId: FarmerChatService.adminId,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text("Recent Conversations"),
              leading: Icon(Icons.chat_bubble_outline),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              subtitle: Text(
                "View your conversation history with admin support",
              ),
              onTap: () {
                _showRecentConversations(context, farmer.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRecentConversations(BuildContext context, String farmerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recent Conversations'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<QuerySnapshot>(
            stream: FarmerChatService().getFarmerChatsStream(farmerId),
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
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No conversations yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF4CAF50),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(data['userName'] ?? 'Admin'),
                    subtitle: Text(
                      data['lastMessage'] ?? 'No messages',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmerChat(
                            farmerId: farmerId,
                            chatId: chatId!,
                            receiverId: FarmerChatService.adminId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
