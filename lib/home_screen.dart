import 'dart:math';

import 'package:app_ic/match_screen.dart';
import 'package:app_ic/profile_screen.dart';
import 'package:flutter/material.dart';
import 'chat/chat_screen.dart';
import 'db/database_helper.dart';
import 'liked_users_screen.dart';
import 'models/models.dart';
import 'auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;
  final List<Meme> preloadedMemes;

  HomeScreen({required this.currentUser, required this.preloadedMemes});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Meme currentMeme;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentMeme = Meme(url: '');
    _loadRandomMeme();
  }

  Future<void> _likeMeme() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (currentMeme.url!.isNotEmpty) {
        await _databaseHelper.insertUserLikedMeme(
          widget.currentUser.id!,
          currentMeme.id!,
        );
        _loadRandomMeme();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error liking meme: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadRandomMeme() async {
    setState(() {
      isLoading = true;
    });

    try {
      final random = Random();
      final randomIndex = random.nextInt(widget.preloadedMemes.length);
      final meme = widget.preloadedMemes[randomIndex];
      setState(() {
        currentMeme = meme;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading random meme from preloaded memes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/images/appic-favicon-color.png',
            height: MediaQuery.of(context).size.height,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        backgroundColor: Color.fromRGBO(72, 147, 126, 1),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(72, 147, 126, 1),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(currentUser: widget.currentUser)),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color.fromRGBO(242, 49, 170, 1),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.currentUser.username!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Center(
                child: Text('Like memes', style: TextStyle(
                    color: Color.fromRGBO(242, 49, 170, 1), fontSize: 20
                )),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(currentUser: widget.currentUser, preloadedMemes: widget.preloadedMemes,)),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Center(
                child: Text('Find match', style: TextStyle(
                    color: Color.fromRGBO(72, 147, 126, 1), fontSize: 20
                )),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MatchScreen(currentUser: widget.currentUser,)),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Center(
                child: Text('Your liked users', style: TextStyle(
                    color: Color.fromRGBO(242, 49, 170, 1), fontSize: 20
                )),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LikedUsersScreen(currentUser: widget.currentUser,)),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Center(
                child: Text('Chat', style: TextStyle(
                    color: Color.fromRGBO(72, 147, 126, 1), fontSize: 20
                )),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(currentUser: widget.currentUser,)),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              currentMeme.url!.isNotEmpty
                  ? Expanded(
                child: Image.network(
                  currentMeme.url!,
                  fit: BoxFit.contain,
                ),
              )
                  : Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                color: Colors.white,
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator(
                    color: Color.fromRGBO(242, 49, 170, 1),
                    backgroundColor: Color.fromRGBO(72, 147, 126, 1),
                  )
                      : Text('No image available'),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _loadRandomMeme(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(242, 49, 170, 1),
                  ),
                  child: Text('Pass', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _likeMeme,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(242, 49, 170, 1),
                  ),
                  child: Text('Like', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

