import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio();
  static const String _kServerUrl = 'server_url';
  static const String _kAuthToken = 'auth_token';
  static const String _kUserId = 'user_id';

  Future<bool> login(String serverUrl, String username, String password) async {
    try {
      // Normalize server URL
      if (!serverUrl.startsWith('http')) {
        serverUrl = 'http://$serverUrl';
      }
      if (serverUrl.endsWith('/')) {
        serverUrl = serverUrl.substring(0, serverUrl.length - 1);
      }

      final response = await _dio.post(
        '$serverUrl/Users/AuthenticateByName',
        data: jsonEncode({
          'Username': username,
          'Pw': password,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Emby-Authorization': 'MediaBrowser Client="FinJelly", Device="Flutter Desktop", DeviceId="finjelly-desktop", Version="1.0.0"',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['AccessToken'];
        final userId = data['User']['Id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kServerUrl, serverUrl);
        await prefs.setString(_kAuthToken, token);
        await prefs.setString(_kUserId, userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
    await prefs.remove(_kUserId);
    // We might want to keep the server URL
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kAuthToken);
  }

  Future<String?> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kServerUrl);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAuthToken);
  }
  
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }
}
