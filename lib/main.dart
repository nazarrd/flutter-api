import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_model.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';

late SharedPreferences sharedPreferences;
UserModel? userData;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  final user = sharedPreferences.getString('userData');
  if (user != null) userData = UserModel.fromJson(jsonDecode(user));

  runApp(MaterialApp(
    title: 'Brief Test',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: userData == null ? const AuthScreen() : const HomeScreen(),
  ));
}
