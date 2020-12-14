import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String message;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  void checkLoggedUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLoggedUser();
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
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<MessageBubble> messageList = [];
                final messages = snapshot.data.docs.reversed;
                for (var message in messages) {
                  final text = message.data()['message'];
                  final sender = message.data()['sender'];
                  final messabub = MessageBubble(
                    text: text,
                    sender: sender,
                    loggeduser: loggedInUser,
                  );
                  messageList.add(messabub);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.all(15.0),
                    children: messageList,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        'timestamp': FieldValue.serverTimestamp(),
                        'message': message,
                        'sender': loggedInUser.email,
                      });
                      messagesStream();
                      textController.clear();
                    },
                    child: Text(
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

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.loggeduser});

  final String text;
  final String sender;
  final User loggeduser;

  CrossAxisAlignment checkSender() {
    if (sender == loggeduser.email) {
      return CrossAxisAlignment.end;
    } else {
      return CrossAxisAlignment.start;
    }
  }

  Material checkusername() {
    if (sender == loggeduser.email) {
      return Material(
        child: null,
      );
    } else {
      return Material(
        // elevation: 5.0,
        // color: Colors.grey,
        borderRadius: sender == loggeduser.email
            ? BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.zero,
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0))
            : BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0)),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            sender,
            style: TextStyle(fontSize: 11.0, color: Colors.black54),
          ),
        ),
      );
    }
  }

  Color checkcolor() {
    if (sender == loggeduser.email) {
      return Colors.lightBlueAccent;
    } else {
      return Colors.lightGreenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: checkSender(),
      children: [
        checkusername(),
        Material(
          elevation: 5.0,
          color: checkcolor(),
          borderRadius: sender == loggeduser.email
              ? BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0))
              : BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              '$text',
              style: TextStyle(
                fontSize: 19.0,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 12.0,
        ),
      ],
    );
  }
}
