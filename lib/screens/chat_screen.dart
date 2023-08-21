import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessage() async {
    final QuerySnapshot<
        Map<String, dynamic>> messagesSnapshot = await FirebaseFirestore
        .instance.collection('Messages').get();

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
            MessagesSteam(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                        color: Colors.black54
                      ),
                      controller: messageTextController ,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('Messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email
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

class MessagesSteam extends StatelessWidget {
  const MessagesSteam({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Messages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageData = message.data() as Map<String, dynamic>; // Explicit cast
            if (messageData != null) {
              final messageText = messageData['text'];
              final messageSender = messageData['sender'];
              final messageBubble = MessageBubble(
                  sender: messageSender,
                  text: messageText
              );
              messageBubbles.add(messageBubble);
            }
          }
          return Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        } else if (snapshot.hasError) {
          // Handle the error case here
          return Text('Error: ${snapshot.error}');
        } else {
          // If snapshot doesn't have data yet, you can return a loading indicator or an empty widget
          return CircularProgressIndicator(); // or return an empty Container()
        }
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
   MessageBubble({required this.sender, required this.text});

  final String sender;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children:<Widget> [
          Text(
              sender,
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black
          ),
          ),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.lightBlue,
            child : Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
              style: const TextStyle(
                fontSize: 15.0
              ),
          ),
            ),
          ),
        ],
      ),
    );
  }
}
