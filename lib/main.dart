import 'package:flutter/material.dart';
import 'api_service/meme_api_service.dart';
import 'auth/auth_screen.dart';
import 'db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database here
  await DatabaseHelper.instance.database;

  // Initialize and schedule meme fetching
  MemeApiService();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'appic',
      theme: ThemeData(fontFamily: 'MonotonRegular'),
      home: AuthScreen(),
    );
  }
}
