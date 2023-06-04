import 'dart:convert';
//import 'dart:io';
import 'package:http/http.dart' as http;

class Image {
  int _id;
  String _name;
  String _path;
  int _userId;
  String _image;

  Image({
    int id = 0,
    required String name,
    required String path,
    required int userId,
    required String image,
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

  String get image => _image;
  set image(String value) => _image = value;

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      userId: json['user_id'],
      image: json['image'], // Decode the base64 image string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': 'add_image',
      'id': _id,
      'name': _name,
      'path': _path,
      'user_id': _userId,
      'image': _image, // Encode the image bytes to base64
    };
  }

  Future<bool> saveImagesRegister() async {
    var data = {
      'command': 'add_images_register',
      'name': name,
      'path': path,
      'user_id': userId.toString(),
      'image': image,
    };

    var encodedData = Uri.encodeComponent(jsonEncode(data));
    var url =
        Uri.parse('http://beoflere.com/confprojekt.php?data=$encodedData');
    try {
      var response = await http.post(url, body: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = response.body;
        if (responseBody == 'ERROR') {
          return false;
        }
        if (responseBody == 'OK') {
          return true;
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  Future<bool> saveImageLogin() async {
    var data = {
      'command': 'add_images_login',
      'name': name,
      'path': path,
      'user_id': userId.toString(),
      'image': image,
    };

    var encodedData = Uri.encodeComponent(jsonEncode(data));
    var url =
        Uri.parse('http://beoflere.com/confprojekt.php?data=$encodedData');
    try {
      var response = await http.post(url, body: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = response.body;
        if (responseBody == 'ERROR') {
          return false;
        }
        if (responseBody == 'OK') {
          return true;
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  static Future<bool> runScriptWithUserId(int userId) async {
    var data = {
      'command': 'runScriptWithUserId',
      'user_id': userId.toString(),
    };

    var encodedData = Uri.encodeComponent(jsonEncode(data));
    var url =
        Uri.parse('http://beoflere.com/confprojekt.php?data=$encodedData');
    try {
      var response = await http.post(url, body: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = response.body;
        print(responseBody);
        if (responseBody == 'ERROR') {
          return false;
        }
        if (responseBody == 'OK') {
          return true;
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }
}
