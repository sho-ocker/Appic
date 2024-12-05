class User {
  final int? id;
  final String? username;
  final String? password;

  User({this.id, this.username, this.password});
}

class Meme {
  final int? id;
  final String? url;
  final String? title;
  final int? nsfw;
  final String? category;

  Meme({
    this.id,
    this.url,
    this.title,
    this.nsfw,
    this.category,
  });
}

class Message {
  final int? id;
  final String? content;
  final int? userId;
  final int? otherUserId;
  final String? timestamp;

  Message({
    this.id,
    this.content,
    this.userId,
    this.otherUserId,
    this.timestamp,
  });
}

class UserMatch {
  final int? id;
  final int? userId;
  final int? likedUser;
  final String? timestamp;

  UserMatch({
    this.id,
    this.userId,
    this.likedUser,
    this.timestamp,
  });
}