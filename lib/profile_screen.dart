import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/models.dart';

class ProfileScreen extends StatefulWidget {
  final User currentUser;

  ProfileScreen({required this.currentUser});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Meme> likedMemes = [];

  @override
  void initState() {
    super.initState();
    _loadLikedMemes();
  }

  Future<void> _loadLikedMemes() async {
    try {
      final List<Meme> likedMemes = await _databaseHelper.getUserLikedMemes(widget.currentUser.id!);
      setState(() {
        this.likedMemes = likedMemes;
      });
    } catch (e) {
      print('Error loading liked memes: $e');
    }
  }

  void _deleteLikedMeme(int memeIndex) async {
    try {
      if (likedMemes.isNotEmpty && memeIndex >= 0 && memeIndex < likedMemes.length) {
        final memeId = likedMemes[memeIndex].id;
        if (memeId != null) {
          await _databaseHelper.deleteUserLikedMeme(widget.currentUser.id!, memeId);
          setState(() {
            likedMemes.removeAt(memeIndex);
          });
        }
      }
    } catch (e) {
      print('Error deleting liked meme: $e');
    }
  }

  void _showMemeDialog(String imageUrl, int memeIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              IconButton(
                icon: Icon(Icons.heart_broken, size: 36, color: Color.fromRGBO(242, 49, 170, 1)),
                onPressed: () {
                  _deleteLikedMeme(memeIndex);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(72, 147, 126, 1),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Data
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Color.fromRGBO(242, 49, 170, 1),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.currentUser.username!,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(72, 147, 126, 1),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          SizedBox(height: 10),
          // Liked Memes
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: likedMemes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showMemeDialog(likedMemes[index].url!, index);
                  },
                  child: Image.network(
                    likedMemes[index].url!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
