import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import 'package:projekt/models/image.dart' as ImageModel;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUserData();
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

  late Uint8List? imageBytes2;
  void addImages() async {
    if (_user == null) {
      // Handle the case where user data is not available
      print('User data is not available');
      return;
    }

    String name = widget.picture.name;
    String path = widget.picture.path;
    int userId = _user!.id;

    Uint8List imageBytes = await File(widget.picture.path).readAsBytes();
    imageBytes2 = await testComporessList(imageBytes);
    String kramp = base64Encode(imageBytes2!);

    var image = ImageModel.Image(name: name, path: path, userId: userId, image: kramp);

    var success = await image.saveImage();

    try {
      if (success) {
        print("Image saved!");
      } else {
        throw Exception("Error occurred while saving the image.");
      }
    } catch (e) {
      print("Error! $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(widget.picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(widget.picture.name),
          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              onPressed: addImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add to Database'),
            ),
          ),
        ]),
      ),
    );
  }
}
