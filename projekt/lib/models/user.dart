import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projekt/settings/shared_preferences.dart';

class User {
  int id;
  String username;
  String password;

  User({
    this.id = 0,
    this.username = "",
    this.password = "",
  });

  int getId() {
    return this.id;
  }

  String getUsername() {
    return this.username;
  }

  void setUsername(String username) {
    this.username = username;
  }

  String getPassword() {
    return this.password;
  }

  void setPassword(String password) {
    this.password = password;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
      };

  Future<bool> saveUser() async {
    var dataStr = jsonEncode({
      "command": "add_user",
      "username": username,
      "password": password,
    });
    var encodedData = Uri.encodeComponent(dataStr);
    var url = Uri.parse("http://beoflere.com/confprojekt.php?data=$encodedData");
    print(url.toString());

    try {
      var result = await http.get(url);
      if (result.body == "ERROR") {
        return false;
      }
      if (result.body == "OK") {
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  Future<bool> getLogin() async {
    var dataStr = jsonEncode({
      "command": "get_login_info",
      "username": username,
      "password": password,
    });
    var url =
        Uri.parse("http://beoflere.com/confprojekt.php?data=" + dataStr);
    try {
      var result = await http.get(url);
      if (result.body == "ERROR") {
        return false;
      }
      if (result.body == "OK") {
        UserPreferences.setUsername(username);
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  static Future<User> getByUsername(String username) async {
    var dataStr = jsonEncode({
      "command": "find_user_by_username",
      "username": username,
    });
    var url =
        Uri.parse("http://beoflere.com/confprojekt.php?data=" + dataStr);
    try {
      var result = await http.get(url);
      if (result.body == "ERROR") {
        return User();
      } else {
        var data =
            jsonDecode(result.body)[0]; // assuming only one user is returned
        print("Retrieved user data: $data");
        return User(
          id: int.parse(data['id']),
          username: data['username'],
          password: data['password'],
        );
      }
    } catch (e) {
      print('Error: $e');
      return User(); // return empty user object on error
    }
  }

  static Future<String?> getUsernameFromPreferences() async {
    return await UserPreferences.getUsername();
  }

  static Future<void> clearUsernameFromPreferences() async {
    return await UserPreferences.clearUsername();
  }

  Future<void> update() async {
    // Code to update user data in MySQL database
  }

  Future<void> delete() async {
    // Code to delete user data from MySQL database
  }
}
