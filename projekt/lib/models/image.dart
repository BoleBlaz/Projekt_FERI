import 'dart:convert';
import 'package:http/http.dart' as http;

class Image {
  int _id;
  String _name;
  String _path;
  int _userId;

  Image({
    int id = 0,
    required String name,
    required String path,
    required int userId,
  })  : _id = id,
        _name = name,
        _path = path,
        _userId = userId;

  int get id => _id;
  set id(int value) => _id = value;

  String get name => _name;
  set name(String value) => _name = value;

  String get path => _path;
  set path(String value) => _path = value;

  int get userId => _userId;
  set userId(int value) => _userId = value;

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': 'add_image', // Add this line
      'id': _id,
      'name': _name,
      'path': _path,
      'user_id': _userId,
    };
  }

  Future<bool> saveImage() async {
    var data = {
      'command': 'add_image',
      'name': name,
      'path': path,
      'user_id': userId.toString(),
    };
    var encodedData = Uri.encodeComponent(jsonEncode(data));
    var url =
        Uri.parse('http://beoflere.com/confprojekt.php?data=$encodedData');

    try {
      var response = await http.post(url);

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
}
