import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/models.dart';

class ChatDetailScreen extends StatefulWidget {
  final User currentUser;
  final User otherUser;

  ChatDetailScreen({required this.currentUser, required this.otherUser});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Widget _buildMessageItem(Message message) {
    final bool isCurrentUser = message.userId == widget.currentUser.id;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Color.fromRGBO(242, 49, 170, 1) : Color.fromRGBO(72, 147, 126, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Color.fromRGBO(72, 147, 126, 1) ,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(_messageController.text);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    // Create a Message object
    Message newMessage = Message(
      content: text,
      userId: widget.currentUser.id,
      otherUserId: widget.otherUser.id,
      timestamp: DateTime.now().toString(),
    );

    // Save the message to the database
    try {
      await _databaseHelper.insertMessage(newMessage);
    } catch (e) {
      print('Error saving message to database: $e');
      // Handle the error as needed
      return;
    }

    // Update the state to add the new message to the messages list
    setState(() {
      messages.add(newMessage);
      _messageController.clear();
    });
  }

  void _loadMessages() async {
    try {
      List<Message> loadedMessages = await _databaseHelper.getMessages(
        widget.currentUser.id!,
        widget.otherUser.id!,
      );

      setState(() {
        messages = loadedMessages;
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherUser.username!,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(72, 147, 126, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(messages[index]);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }
}
