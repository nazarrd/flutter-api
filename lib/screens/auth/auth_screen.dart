import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../shared/progress_dialog.dart';
import '../../shared/snackbar_default.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn() async {
    progressDialog(context);
    try {
      final signIn = await _googleSignIn.signIn();
      Navigator.pop(context);
      if (signIn?.email != null) {
        userData = UserModel(
          id: signIn?.id,
          email: signIn?.email,
          displayName: signIn?.displayName,
          photoUrl: signIn?.photoUrl,
        );
        await sharedPreferences.setString('userData', jsonEncode(userData));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        snackBarDefault(context, text: 'Login failed, please try again later.');
      }
    } catch (error) {
      Navigator.pop(context);
      snackBarDefault(context,
          text: 'An error occured, please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.face, size: 100),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _handleSignIn(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Sign in with Google',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}
