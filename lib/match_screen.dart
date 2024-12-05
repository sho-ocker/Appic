import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'models/models.dart';

class MatchScreen extends StatefulWidget {
  final User currentUser;

  MatchScreen({required this.currentUser});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late User currentUser;
  List<User> potentialMatches = [];
  List<int> passedUserIds = [];
  List<User> likedUsers = [];
  Map<int, List<Meme>> userLikedMemesMap = {};

  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    _loadPotentialMatches();
  }

  void _resetUserLikedMemes() {
    setState(() {
      userLikedMemesMap.clear();
    });
  }

  void _likeUser(User likedUser) async {
    try {
      await _databaseHelper.insertUserMatch(currentUser.id!, likedUser.id!);
      bool isMatch = await _databaseHelper.checkUserMatch(likedUser.id!, currentUser.id!);
      if (isMatch) {
        _showMatchDialog(likedUser.username!);
      }
      likedUsers.add(likedUser);
      _loadPotentialMatches();
      _resetUserLikedMemes();
    } catch (e) {
      print('Error liking user: $e');
    }
  }

  void _passUser(User passedUser) {
    setState(() {
      passedUserIds.add(passedUser.id!);
      potentialMatches.remove(passedUser);
    });
  }

  void _loadPotentialMatches() async {
    try {
      _resetUserLikedMemes();
      final List<User> matches = await _databaseHelper.getPotentialMatches(currentUser.id!);

      // Filter out passed and liked users from potential matches
      potentialMatches = matches.where((user) => !passedUserIds.contains(user.id) && !likedUsers.contains(user)).toList();

      setState(() {}); // Update state to trigger UI rebuild with potential matches

      // Load liked memes for all potential matches
      for (var match in potentialMatches) {
        await _loadUserLikedMemes(match);
      }
    } catch (e) {
      print('Error loading potential matches: $e');
    }
  }

  Future<void> _loadUserLikedMemes(User user) async {
    try {
      final List<Meme> likedMemes = await _databaseHelper.getUserLikedMemes(user.id!);
      setState(() {
        userLikedMemesMap[user.id!] = likedMemes;
      });
    } catch (e) {
      print('Error loading userLikedMemes: $e');
    }
  }

  void _showMemeDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 400,
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMatchDialog(String matchedUsername) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Match!'),
          content: Text('You matched with $matchedUsername'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find people', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(72, 147, 126, 1),
      ),
      body: potentialMatches.isNotEmpty
          ? Card(
        elevation: 5,
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: Color.fromRGBO(72, 147, 126, 1),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${potentialMatches.first.username}',
                style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'MonotonRegular',
                  color: Color.fromRGBO(72, 147, 126, 1),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: userLikedMemesMap[potentialMatches.first.id!]?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _showMemeDialog(userLikedMemesMap[potentialMatches.first.id!]![index].url!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          userLikedMemesMap[potentialMatches.first.id!]![index].url!,
                          width: 100,
                          height: 100,
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
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Center(
          child: Text(
            'No potential matches found',
            style: TextStyle(fontSize: 18, color: Color.fromRGBO(242, 49, 170, 1)),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                if (potentialMatches.isNotEmpty) {
                  _passUser(potentialMatches.first);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(242, 49, 170, 1),
              ),
              child: Text('Pass', style: TextStyle(color: Colors.white, fontSize: 25)),
            ),
            ElevatedButton(
              onPressed: () {
                if (potentialMatches.isNotEmpty) {
                  _likeUser(potentialMatches.first);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(242, 49, 170, 1),
              ),
              child: Text('Like', style: TextStyle(color: Colors.white, fontSize: 25)),
            ),
          ],
        ),
      ),
    );
  }
}
