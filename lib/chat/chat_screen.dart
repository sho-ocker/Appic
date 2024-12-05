import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/models.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final User currentUser;

  ChatScreen({required this.currentUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<User> mutualLikes = [];

  @override
  void initState() {
    super.initState();
    _loadMutualLikes();
  }

  void _loadMutualLikes() async {
    try {
      final List<User> likes = await _databaseHelper.getMutualLikes(widget.currentUser.id!);
      setState(() {
        mutualLikes = likes;
      });
    } catch (e) {
      print('Error loading mutual likes: $e');
    }
  }

  void _startChat(User otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(currentUser: widget.currentUser, otherUser: otherUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(72, 147, 126, 1),
      ),
      body: mutualLikes.isNotEmpty
          ? ListView.builder(
        itemCount: mutualLikes.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Color.fromRGBO(242, 49, 170, 1),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              title: Text(
                mutualLikes[index].username!,
                style: TextStyle(fontSize: 25),
              ),
              onTap: () {
                _startChat(mutualLikes[index]);
              },
            ),
          );
        },
      )
          : Center(
        child: Text(
          'No matches yet.',
          style: TextStyle(fontSize: 22, color: Color.fromRGBO(242, 49, 170, 1)),
        ),
      ),
    );
  }
}
