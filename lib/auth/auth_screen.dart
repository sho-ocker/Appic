import 'package:app_ic/db/database_helper.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';
import '../models/models.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? loginError;
  User? currentUser;
  bool isMemesPreloaded = false;
  late List<Meme> preloadedMemes;


  @override
  void initState() {
    super.initState();
    _preloadMemes();
  }

  void _preloadMemes() async {
    try {
      preloadedMemes = await DatabaseHelper.instance.getRandomMemesFromDatabase(20);
      setState(() {
        isMemesPreloaded = true;
      });
    } catch (e) {
      print('Error preloading memes: $e');
    }
  }

  String? _validateUsernameNotEmpty(String value) {
    if (value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  String? _validatePasswordNotEmpty(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    String? usernameError = _validateUsernameNotEmpty(username);
    String? passwordError = _validatePasswordNotEmpty(password);

    if (usernameError == null && passwordError == null) {
      // Check if the username and password match in the database
      currentUser = await DatabaseHelper.instance.getUserByUsernameAndPassword(username, password);

      if (currentUser != null) {
        print('Login successful with username: $username, password: $password');
        // Navigate to the home screen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(currentUser: currentUser!, preloadedMemes: preloadedMemes),
          ),
        );
      } else {
        setState(() {
          loginError = 'Username or password do not match';
        });
      }
    } else {
      setState(() {
        loginError = 'Missing username or password';
      });
    }
  }

  Future<void> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    String? usernameError = _validateUsernameNotEmpty(username);
    String? passwordError = _validatePasswordNotEmpty(password);

    if (usernameError == null && passwordError == null) {
      // Check if the user already exists in the database based on the username
      User? existingUser = await DatabaseHelper.instance.getUserByUsername(username);

      if (existingUser == null) {
        setState(() {
          loginError = null; // Clear previous error
        });

        try {
          User newUser = User(username: username, password: password);
          // Attempt to register the user
          await DatabaseHelper.instance.insertUser(newUser);

          print('Registration successful with username: $username, password: $password');
          // Navigate to the home screen on successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(currentUser: currentUser!, preloadedMemes: preloadedMemes),
            ),
          );
        } catch (e) {
          setState(() {
            loginError = 'Registration failed. An error occurred.';
          });
        }
      } else {
        setState(() {
          loginError = 'Username already exists';
        });
      }
    } else {
      setState(() {
        loginError = 'Missing username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isMemesPreloaded ?
     Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/appic-high-resolution-logo-transparent.png',
                  height: 300,
                  width: 300,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  style: TextStyle(color: Color.fromRGBO(242, 49, 170, 1)),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Color.fromRGBO(72, 147, 126, 1)),
                    prefixIcon: Icon(Icons.person, color: Color.fromRGBO(72, 147, 126, 1)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      loginError = null;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Color.fromRGBO(242, 49, 170, 1)),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color.fromRGBO(72, 147, 126, 1)),
                    prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(72, 147, 126, 1)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      loginError = null;
                    });
                  },
                ),
                SizedBox(height: 20),
                if (loginError != null)
                  Text(
                    loginError!,
                    style: TextStyle(color: Color.fromRGBO(242, 49, 170, 1)),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(242, 49, 170, 1),
                      ),
                      child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(242, 49, 170, 1),
                      ),
                      child: Text('Register', style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                  },
                  child: Text('Forgot Password?', style: TextStyle(color: Color.fromRGBO(72, 147, 126, 1))),
                ),
              ],
            ),
          ),
        ),
      ),
    ) : Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

