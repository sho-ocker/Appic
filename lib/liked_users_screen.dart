import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/models.dart';

class LikedUsersScreen extends StatefulWidget {
  final User currentUser;

  LikedUsersScreen({required this.currentUser});

  @override
  _LikedUsersScreenState createState() => _LikedUsersScreenState();
}

class _LikedUsersScreenState extends State<LikedUsersScreen> {
  late List<User> likedUsers;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _getLikedUsers();
  }

  Future<void> _getLikedUsers() async {
    try {
      List<User> users = await _databaseHelper.getLikedUsers(widget.currentUser.id!);
      setState(() {
        likedUsers = users;
      });
    } catch (e) {
      print('Error fetching liked users: $e');
    }
  }

  Future<void> _showLikedMemesPopup(User likedUser) async {
    List<Meme> likedMemes = await _databaseHelper.getUserLikedMemes(likedUser.id!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // Adjust width as needed
            height: MediaQuery.of(context).size.height * 0.7, // Adjust height as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: likedMemes.length,
                    itemBuilder: (context, index) {
                      Meme meme = likedMemes[index];
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            meme.url ?? '',
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Users', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(72, 147, 126, 1),
      ),
      body: likedUsers.isNotEmpty
          ? ListView.builder(
        itemCount: likedUsers.length,
        itemBuilder: (context, index) {
          User user = likedUsers[index];
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
                user.username!,
                style: TextStyle(fontSize: 25),
              ),
              onTap: () => _showLikedMemesPopup(user),
            ),
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
