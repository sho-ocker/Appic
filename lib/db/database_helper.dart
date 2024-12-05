import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'baza.db');
    return await openDatabase(path, version: 1);
  }

  // CRUD FOR USERS ---------------------------------------------------------------

  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    Map<String, dynamic> userMap = {
      'username': user.username,
      'password': user.password
    };
    return await db.insert('users', userMap);
  }

  Future<User?> getUserByUsername(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> userMap = await db.rawQuery(
      'SELECT * FROM users WHERE username = ?',
      [username],
    );

    if (userMap.isNotEmpty) {
      return User(
        id: userMap.first['id'],
        username: userMap.first['username'],
      );
    } else {
      return null;
    }
  }

  Future<User?> getUserByUsernameAndPassword(String username, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM users WHERE username = ? and password = ?',
      [username, password],
    );

    if (result.isNotEmpty) {
      Map<String, dynamic> userMap = result.first;
      User user = User(
        id: userMap['id'],
        username: userMap['username'],
        password: userMap['password'],
      );
      return user;
    } else {
      return null;
    }
  }

  // CRUD FOR MEMES  ---------------------------------------------------------------

  Future<int> insertMeme(Meme meme) async {
    final db = await instance.database;
    return await db.insert("meme", {
      'url': meme.url,
      'title': meme.title,
      'nsfw': meme.nsfw != null ? 1 : 0,
      'category': meme.category,
    });
  }

  Future<Meme?> getRandomMemeFromDatabase() async {
    try {
      final List<Meme> allMemes = await DatabaseHelper.instance.getAllMemes();
      if (allMemes.isEmpty) {
        return null;
      }

      final Random random = Random();
      final int randomIndex = random.nextInt(allMemes.length);
      final Meme randomMeme = allMemes[randomIndex];

      final response = await http.get(Uri.parse(randomMeme.url!));
      if (response.statusCode == 200) {
        return randomMeme;
      } else {
        print('Error loading random meme image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting random meme from database: $e');
      return null;
    }
  }

  Future<List<Meme>> getRandomMemesFromDatabase(int count) async {
    try {
      final Database db = await instance.database;
      final List<Map<String, dynamic>> result =
      await db.rawQuery('SELECT * FROM meme ORDER BY RANDOM() LIMIT $count');

      return result.map((map) {
        return Meme(
          id: map['id'],
          url: map['url'],
          title: map['title'],
          nsfw: map['nsfw'],
          category: map['category'],
        );
      }).toList();
    } catch (e) {
      print('Error getting random memes from database: $e');
      return [];
    }
  }

  Future<List<Meme>> getAllMemes() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query('meme');
    return result.map((map) => Meme(
      id: map['id'],
      url: map['url'],
      title: map['title'],
      nsfw: map['nsfw'],
      category: map['category'],
    )).toList();
  }


  Future<Meme?> getMemeByUrl(String url) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query('meme', where: 'url = ?', whereArgs: [url]);

    if (result.isNotEmpty) {
      return Meme(
        id: result.first['id'],
        url: result.first['url'],
        title: result.first['title'],
        nsfw: result.first['nsfw'],
        category: result.first['category'],
      );
    } else {
      return null;
    }
  }

  // CRUD FOR USER LIKED MEMES  ---------------------------------------------------------------

  Future<int> insertUserLikedMeme(int userId, int memeId) async {
    final db = await instance.database;
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}";

    return await db.insert('user_liked_memes', {
      'user_id': userId,
      'meme_id': memeId,
      'date': formattedDate,
    });
  }

  Future<List<Meme>> getUserLikedMemes(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM user_liked_memes '
          'INNER JOIN meme ON user_liked_memes.meme_id = meme.id '
          'WHERE user_liked_memes.user_id = ?',
      [userId],
    );

    return result.map((map) {
      return Meme(
        id: map['id'],
        url: map['url'],
        title: map['title'],
        nsfw: map['nsfw'],
        category: map['category'],
      );
    }).toList();
  }

  Future<List<Meme>> getRandomUserLikedMemes(int userId, {int count = 3}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT meme.url FROM user_liked_memes '
          'INNER JOIN meme ON user_liked_memes.meme_id = meme.id '
          'WHERE user_liked_memes.user_id = ? '
          'ORDER BY RANDOM() LIMIT ?',
      [userId, count],
    );

    return result.map((map) => Meme(url: map['url'])).toList();
  }

  Future<void> deleteUserLikedMeme(int userId, int memeId) async {
    final db = await instance.database;
    await db.delete(
      'user_liked_memes',
      where: 'user_id = ? AND meme_id = ?',
      whereArgs: [userId, memeId],
    );
  }

  // CRUD FOR USER MATCHES  ---------------------------------------------------------------

  Future<int> insertUserMatch(int userId, int likedUserId) async {
    final db = await instance.database;
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}";

    return await db.insert('user_match', {
      'user_id': userId,
      'liked_user': likedUserId,
      'date_of_match': formattedDate,
    });
  }

  Future<List<User>> getPotentialMatches(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT users.id, users.username FROM users '
          'WHERE users.id <> ? AND users.id NOT IN '
          '(SELECT liked_user FROM user_match WHERE user_id = ?) '
          'ORDER BY RANDOM() LIMIT 10',
      [userId, userId],
    );

    return result.map((map) => User(id: map['id'], username: map['username'])).toList();
  }

  Future<List<User>> getMutualLikes(int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT u.* FROM users u '
          'INNER JOIN user_match um1 ON u.id = um1.liked_user '
          'INNER JOIN user_match um2 ON u.id = um2.user_id '
          'WHERE um1.user_id = ? AND um2.liked_user = ?',
      [userId, userId],
    );

    return result.map((map) => User(
      id: map['id'],
      username: map['username']
    )).toList();
  }

  Future<bool> checkUserMatch(int userId1, int userId2) async {
    final db = await instance.database;

    List<Map<String, dynamic>> result1 = await db.rawQuery(
      'SELECT * FROM user_match WHERE user_id = ? AND liked_user = ?',
      [userId1, userId2],
    );

    List<Map<String, dynamic>> result2 = await db.rawQuery(
      'SELECT * FROM user_match WHERE user_id = ? AND liked_user = ?',
      [userId2, userId1],
    );

    return result1.isNotEmpty && result2.isNotEmpty;
  }

  Future<List<User>> getLikedUsers(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT u.* FROM users u '
          'INNER JOIN user_match um ON u.id = um.liked_user '
          'WHERE um.user_id = ?',
      [userId],
    );

    return result.map((map) => User(
      id: map['id'],
      username: map['username']
    )).toList();
  }

  //CRUD FOR MESSAGES  ---------------------------------------------------------------

  Future<int> insertMessage(Message message) async {
    final db = await instance.database;
    return await db.insert('messages', {
      'content': message.content,
      'user_id': message.userId,
      'other_user_id': message.otherUserId,
      'timestamp': message.timestamp,
    });
  }

  Future<List<Message>> getMessages(int userId, int otherUserId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'messages',
      where: '(user_id = ? AND other_user_id = ?) OR (user_id = ? AND other_user_id = ?)',
      whereArgs: [userId, otherUserId, otherUserId, userId],
      orderBy: 'timestamp ASC',
    );

    return result.map((map) => Message(
      id: map['id'],
      content: map['content'],
      userId: map['user_id'],
      otherUserId: map['other_user_id'],
      timestamp: map['timestamp'],
    )).toList();
  }
}
