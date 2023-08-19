import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {

  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore  = FirebaseFirestore.instance;
  late User loggedInUser;
  late String  messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if(user != null) {
        loggedInUser = user;
      }
    }catch(e) {
      print(e);
    }
  }

  void getMessage() async {
    final QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await FirebaseFirestore.instance.collection('Messages').get();

    for (var msg in messagesSnapshot.docs) {
      print(msg.data());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
               _auth.signOut();
               Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Messages').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  List<Widget> messageWidgets = [];
                  for (var message in messages) {
                    final messageData = message.data() as Map<String, dynamic>; // Explicit cast
                    if (messageData != null) {
                      final messageText = messageData['text'];
                      final messageSender = messageData['sender'];
                      final messageWidget = Text('$messageText from $messageSender');
                      messageWidgets.add(messageWidget);
                    }
                  }
                  return Column(
                    children: messageWidgets,
                  );
                } else if (snapshot.hasError) {
                  // Handle the error case here
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If snapshot doesn't have data yet, you can return a loading indicator or an empty widget
                  return CircularProgressIndicator(); // or return an empty Container()
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _firestore.collection('Messages').add({
                        'text': messageText,
                        'sender':loggedInUser.email
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
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
