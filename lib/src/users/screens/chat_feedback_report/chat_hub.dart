import 'package:denbigh_app/src/users/database/chat_service.dart';
import 'package:denbigh_app/src/users/screens/chat_feedback_report/feedback.dart';
import 'package:denbigh_app/src/users/screens/chat_feedback_report/user_chat.dart';
import 'package:denbigh_app/src/users/screens/dashboard/home.dart';
import 'package:flutter/material.dart';

class ChatHub extends StatefulWidget {
  const ChatHub({super.key});

  @override
  State<ChatHub> createState() => _ChatHubState();
}

class _ChatHubState extends State<ChatHub> {
  String? chatId;

  @override
  void initState() {
    super.initState();
    getChatId();
  }

  void getChatId() async {
    final id = await ChatService().getChatId(
      auth!.uid,
      "L235HWCbg2ZJqc3l8KKlvL10HK82",
    );
    setState(() {
      chatId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chatId == null) {
      // Show a loading indicator while fetching chatId
      return Scaffold(
        appBar: AppBar(title: Text("Chat Hub")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text("Chat Hub"), centerTitle: true),
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
              title: Text("Report a Farmer"),
              leading: Icon(Icons.report_problem),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              subtitle: Text(
                "Any altercation with recieving a package or with a farmer should be reported Immediately",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserChat(
                      userId: auth!.uid,
                      chatId: chatId!,
                      recieverId: "L235HWCbg2ZJqc3l8KKlvL10HK82",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
