import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _USERNAME_KEY = 'username';

  static Future<String?> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? usernameWithExpiration = prefs.getString(_USERNAME_KEY);
    if (usernameWithExpiration == null) {
      return null;
    }
    final List<String> parts = usernameWithExpiration.split('#');
    final String username = parts[0];
    final int expirationTime = int.parse(parts[1]);
    final DateTime now = DateTime.now();
    if (now.millisecondsSinceEpoch > expirationTime) {
      await clearUsername();
      return null;
    }
    return username;
  }

  static Future<void> setUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    final int expirationTime =
        //now.add(Duration(minutes: 1)).millisecondsSinceEpoch;
        now.add(Duration(days: 7)).millisecondsSinceEpoch;
    await prefs.setString(_USERNAME_KEY, '$username#$expirationTime');
  }

  static Future<void> clearUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_USERNAME_KEY);
  }
}
