import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projekt/settings/shared_preferences.dart';

class User {
  int id;
  String username;
  String password;
  int fa;

  User({
    this.id = 0,
    this.username = "",
    this.password = "",
    this.fa = 0,
  });

  int getId() {
    return id;
  }

  String getUsername() {
    return username;
  }

  void setUsername(String username) {
    this.username = username;
  }

  String getPassword() {
    return password;
  }

  void setPassword(String password) {
    this.password = password;
  }

   int getTwoFactorAuth() {
    return fa;
  }

  void setTwoFactorAuth(int fa) {
    this.fa = fa;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      fa: json['fa'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'fa': fa,
      };

  Future<bool> saveUser() async {
    var dataStr = jsonEncode({
      "command": "add_user",
      "username": username,
      "password": password,
    });
    var encodedData = Uri.encodeComponent(dataStr);
    var url =
        Uri.parse("http://beoflere.com/confprojekt.php?data=$encodedData");

    try {
      var result = await http.get(url);
      if (result.body == "ERROR") {
        return false;
      }
      if (result.body == "OK") {
        return true;
      }
    } catch (e) {}
    return false;
  }

  Future<bool> getLogin() async {
    var dataStr = jsonEncode({
      "command": "get_login_info",
      "username": username,
      "password": password,
    });
    var url = Uri.parse("http://beoflere.com/confprojekt.php?data=$dataStr");
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
      return false;
    }
    return false;
  }

  static Future<bool> update2FA(int userId) async {
    var dataStr = jsonEncode({
      "command": "update_fa",
      "user_id": userId,
    });
    var url = Uri.parse("http://beoflere.com/confprojekt.php?data=$dataStr");
    try {
      var result = await http.get(url);
      if (result.body == "ERROR") {
        return false;
      }
      if (result.body == "OK") {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static Future<User> getByUsername(String username) async {
    var dataStr = jsonEncode({
      "command": "find_user_by_username",
      "username": username,
    });
    var url = Uri.parse("http://beoflere.com/confprojekt.php?data=$dataStr");
    try {
      var result = await http.get(url);
      if (result.body == "ERROR") {
        return User();
      } else {
        var data =
            jsonDecode(result.body)[0]; // assuming only one user is returned
        return User(
          id: int.parse(data['id']),
          username: data['username'],
          password: data['password'],
          fa: int.parse(data['fa']),
        );
      }
    } catch (e) {
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
