import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import 'package:projekt/models/image.dart' as ImageModel;

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

  void addImage() async {
    String name = widget.picture.name;
    String path = widget.picture.path;
    int userId = _user!.id;

    var image = ImageModel.Image(name: name, path: path, userId: userId);
    var success = await image.saveImage();
    if (success) {
      print("Image saved!");
    } else {
      print("Error!");
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
              onPressed: addImage,
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
