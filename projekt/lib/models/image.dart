import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Image {
  int _id;
  String _name;
  String _path;
  int _userId;
  Uint8List _image;

  Image({
    int id = 0,
    required String name,
    required String path,
    required int userId,
    required Uint8List image,
  })  : _id = id,
        _name = name,
        _path = path,
        _userId = userId,
        _image = image;

  int get id => _id;
  set id(int value) => _id = value;

  String get name => _name;
  set name(String value) => _name = value;

  String get path => _path;
  set path(String value) => _path = value;

  int get userId => _userId;
  set userId(int value) => _userId = value;

  Uint8List get image => _image;
  set image(Uint8List value) => _image = value;

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      userId: json['user_id'],
      image: base64Decode(json['image']), // Decode the base64 image string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': 'add_image',
      'id': _id,
      'name': _name,
      'path': _path,
      'user_id': _userId,
      'image': base64Encode(_image), // Encode the image bytes to base64
    };
  }

  Future<bool> saveImage() async {
    var dataStr = jsonEncode({
      'command': 'add_image',
      'name': _name,
      'path': _path,
      'user_id': _userId,
      //'image': base64Encode(_image),
    });
    var encodedData = Uri.encodeComponent(dataStr);
    var url =
        Uri.parse('http://beoflere.com/confprojekt.php?data=$encodedData');
    try {
      var result = await http.get(url);
      if (result.body == 'ERROR') {
        return false;
      }
      if (result.body == 'OK') {
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }
}
