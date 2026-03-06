import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Use 10.0.2.2 for Android emulator to access host localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://localhost:7148';
    } else if (Platform.isAndroid) {
      return 'https://10.0.2.2:7148';
    } else {
      return 'https://localhost:7148';
    }
  }

  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];

        // Save token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        await prefs.setString(userKey, jsonEncode(user));

        return {'success': true, 'data': data};
      } else {
        // Parse error message if available
        String errorMessage = 'Failed to login';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Ignore parse errors, use default message
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Login network error: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  // Helper method to retrieve token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Helper method to clear token on logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }
}
