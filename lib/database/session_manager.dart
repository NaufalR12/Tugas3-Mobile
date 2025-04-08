import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Keys
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUsername = 'username';
  static const String keyUserId = 'userId';

  // Save login session
  static Future<void> saveLoginSession(String username, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUsername, username);
    await prefs.setInt(keyUserId, userId);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // Get logged in user data
  static Future<Map<String, dynamic>> getLoggedInUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(keyUsername) ?? '',
      'userId': prefs.getInt(keyUserId) ?? 0,
    };
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUserId);
  }
}
