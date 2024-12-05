import 'dart:convert';
import 'package:cron/cron.dart';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';
import '../models/models.dart';

class MemeApiService {
  MemeApiService() {
    //fetchBatchOfMemes(50);
    // Schedule the fetchBatchOfMemes function to run every X minutes
    final cron = Cron();
    cron.schedule(Schedule.parse('*/30 * * * *'), () async {
      await fetchBatchOfMemes(50);
    });
  }

  Future<Meme> fetchRandomMeme() async {
    final response = await http.get(Uri.parse('https://meme-api.com/gimme'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Meme(
        url: data['url'],
        title: data['title'],
        nsfw: data['nsfw'],
        category: data['subreddit'],
      );
    } else {
      throw Exception('Failed to load meme');
    }
  }

  Future<void> fetchBatchOfMemes(int count) async {
    try {
      final List<Meme> memes = await _getBatchOfMemes(count);
      await _saveMemesToDatabase(memes);
    } catch (e) {
      print('Error fetching and saving memes: $e');
    }
  }

  Future<List<Meme>> _getBatchOfMemes(int count) async {
    final response = await http.get(Uri.parse('https://meme-api.com/gimme/$count'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['memes'];
      return data.map((memeData) => Meme(
        url: memeData['url'],
        title: memeData['title'],
        nsfw: memeData['nsfw'] ? 1 : 0,
        category: memeData['subreddit'],
      )).toList();
    } else {
      throw Exception('Failed to load memes');
    }
  }

  Future<void> _saveMemesToDatabase(List<Meme> memes) async {
    final DatabaseHelper databaseHelper = DatabaseHelper.instance;

    for (final meme in memes) {
      final existingMeme = await databaseHelper.getMemeByUrl(meme.url!);

      if (existingMeme == null) {
        await databaseHelper.insertMeme(meme);
        print("inserted - $meme");
      }
    }
  }
}
