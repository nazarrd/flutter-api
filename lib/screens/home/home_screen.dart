import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';
import '../../models/post_model.dart';
import '../../shared/bottom_sheet_default.dart';
import '../../shared/snackbar_default.dart';
import '../auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? tmpImgPath;
  bool isLoading = true;
  List<PostModel> listPost = [];

  Future<void> _doLogout() async {
    await sharedPreferences.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  Future<void> _pickImage({ImageSource source = ImageSource.camera}) async {
    var camera = await Permission.camera.status;
    if (camera.isGranted) {
      final image = await ImagePicker().pickImage(source: source);
      if (image != null) setState(() => tmpImgPath = File(image.path));
    } else if (camera.isPermanentlyDenied) {
      openAppSettings();
    } else {
      await Permission.camera.request();
    }
  }

  Future<void> _getPost() async {
    setState(() {
      isLoading = true;
      listPost.clear();
    });
    try {
      final response =
          await Dio().get('https://jsonplaceholder.typicode.com/posts');
      setState(() => isLoading = false);
      if (response.statusCode == 200) {
        response.data.forEach((v) => listPost.add(PostModel.fromJson(v)));
      } else {
        snackBarDefault(context,
            text: 'Get post failsed, please try again later.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      snackBarDefault(context,
          text: 'An error occured, please try again later.');
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _getPost());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const SizedBox(height: kToolbarHeight),
        InkWell(
          onTap: () => _chooseSource(context),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Stack(alignment: Alignment.bottomCenter, children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: tmpImgPath == null ? null : Colors.transparent,
              child: tmpImgPath == null
                  ? const Icon(Icons.face, size: 100)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.file(tmpImgPath!, fit: BoxFit.cover),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Change Photo',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Text(
              'Hi, ${userData?.displayName ?? 'User'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              userData?.email ?? '-',
              style: const TextStyle(color: Colors.blue),
            ),
          ]),
        ),
        ElevatedButton(
          onPressed: () => _doLogout(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: const Text.rich(
            TextSpan(
              text: 'List Post',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              children: [
                TextSpan(
                  text: '\nsource: https://jsonplaceholder.typicode.com/posts',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _getPost,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: 0.75,
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    ...listPost.map((e) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title ?? '-',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text((e.body ?? '-').replaceAll('\n', ' ')),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }

  Future<dynamic> _chooseSource(BuildContext context) {
    return bottomSheetDefault(
      context,
      child: Column(children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Choose Image Source',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 13),
        Column(
          children: [ImageSource.camera, ImageSource.gallery].map((e) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
                _pickImage(source: e);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(children: [
                  Icon(
                    e == ImageSource.camera ? Icons.camera_alt : Icons.image,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e == ImageSource.camera ? 'Camera' : 'Gallery',
                  ),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}
