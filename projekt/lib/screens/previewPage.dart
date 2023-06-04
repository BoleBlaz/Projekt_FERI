import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/image.dart' as ImageModel;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.pictureList}) : super(key: key);

  final List<XFile> pictureList;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  User? _user;
  String text = "0";
  int insertCounter = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    widget.pictureList.clear();
    super.dispose();
  }

  Future<void> _getUserData() async {
    String? username = await User.getUsernameFromPreferences();
    User user = await User.getByUsername(username!);
    setState(() {
      _user = user;
    });
  }

  Future<Uint8List> testComporessList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 200,
      minWidth: 100,
      quality: 50,
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 4, // Number of columns in the grid
              children: List.generate(widget.pictureList.length, (index) {
                XFile picture = widget.pictureList[index];
                return Column(
                  children: [
                    Expanded(
                      child: Image.file(File(picture.path), fit: BoxFit.cover),
                    ),
                  ],
                );
              }),
            ),
          ),
          Text(
            _user?.fa == 0 ? "PRESS TO ADD REGISTER IMAGES TO DATABSE -->" : "PRESS TO ADD LOGIN IMAGES TO DATABSE -->",
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _user?.fa == 0 ? addImagesRegister : addImageLogin,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      
    );
  }

  Future<void> addImagesRegister() async {
    if (_user == null) {
      // Handle the case where user data is not available
      print('User data is not available');
      return;
    }
    for (XFile picture in widget.pictureList) {
      String name = picture.name;
      String path = picture.path;
      int userId = _user!.id;

      Uint8List imageBytes = await File(picture.path).readAsBytes();
      Uint8List compressedBytes = await testComporessList(imageBytes);
      String encodedImage = base64Encode(compressedBytes);

      var image = ImageModel.Image(
          name: name, path: path, userId: userId, image: encodedImage);

      var success = await image.saveImagesRegister();

      try {
        if (success) {
          print("Image saved!");
          setState(() {
            insertCounter++;
            text = insertCounter.toString();
          });
        } else {
          throw Exception("Error occurred while saving the image.");
        }
      } catch (e) {
        print("Error! $e");
      }
    }
    User.update2FA(_user!.id);
    setState(() {
      text = "DONE";
    });
  }

  Future<void> addImageLogin() async {
    if (_user == null) {
      // Handle the case where user data is not available
      print('User data is not available');
      return;
    }
    for (XFile picture in widget.pictureList) {
      String name = picture.name;
      String path = picture.path;
      int userId = _user!.id;

      Uint8List imageBytes = await File(picture.path).readAsBytes();
      Uint8List compressedBytes = await testComporessList(imageBytes);
      String encodedImage = base64Encode(compressedBytes);

      var image = ImageModel.Image(
          name: name, path: path, userId: userId, image: encodedImage);

      var success = await image.saveImageLogin();

      try {
        if (success) {
          print("Image saved!");
          setState(() {
            insertCounter++;
            text = insertCounter.toString();
          });
        } else {
          throw Exception("Error occurred while saving the image.");
        }
      } catch (e) {
        print("Error! $e");
      }
    }
    setState(() {
      text = "DONE";
    });
  }
}
