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

  Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    try {
      // Auto detect: if input contains '@' it's an email, otherwise phone number
      final bool isEmail = emailOrPhone.contains('@');

      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (isEmail) 'email': emailOrPhone else 'phoneNumber': emailOrPhone,
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

  Future<Map<String, dynamic>> forgotPassword({String? email, String? phoneNumber}) async {
    try {
      final Map<String, dynamic> body = {};
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phoneNumber'] = phoneNumber;
      } else if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'OTP sent'};
      } else {
        String errorMessage = 'Failed to send OTP';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Forgot Password network error: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({String? email, String? phoneNumber, required String otp, required String newPassword}) async {
    try {
      final Map<String, dynamic> body = {
        'otp': otp,
        'newPassword': newPassword,
      };
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phoneNumber'] = phoneNumber;
      } else if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'Password reset successfully'};
      } else {
        String errorMessage = 'Failed to reset password';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Reset Password network error: $e');
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

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load profile'};
      }
    } catch (e) {
      print('Network error fetching profile: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getAttendanceSummary() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Attendance/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load attendance summary'};
      }
    } catch (e) {
      print('Network error fetching attendance summary: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getMonthlyAttendance(int year, int month) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Attendance/monthly?year=$year&month=$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load monthly attendance'};
      }
    } catch (e) {
      print('Network error fetching monthly attendance: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getAcademicResults() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/academic-results'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load academic results'};
      }
    } catch (e) {
      print('Network error fetching academic results: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }
  Future<Map<String, dynamic>> getTimetable() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Timetable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load timetable'};
      }
    } catch (e) {
      print('Network error fetching timetable: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<Map<String, dynamic>> getLeaveRequests() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/leave-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load leave requests'};
      }
    } catch (e) {
      print('Network error fetching leave requests: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> submitLeaveRequest({
    required DateTime requestDate,
    required String reason,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/leave-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'requestDate': requestDate.toIso8601String(),
          'reason': reason,
        }),
      );

      // Return 201 Created
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        String errorMessage = 'Failed to submit leave request';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Network error submitting leave request: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> updateLeaveRequest({
    required int id,
    required DateTime requestDate,
    required String reason,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/leave-requests/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'requestDate': requestDate.toIso8601String(),
          'reason': reason,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        String errorMessage = 'Failed to update leave request';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Network error updating leave request: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> deleteLeaveRequest(int id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/leave-requests/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        String errorMessage = 'Failed to delete leave request';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Network error deleting leave request: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }
  Future<Map<String, dynamic>> getNotes() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Notes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load notes'};
      }
    } catch (e) {
      print('Network error fetching notes: $e');
      return {'success': false, 'message': 'Network error (\$e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getNews() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/News'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load news'};
      }
    } catch (e) {
      print('Network error fetching news: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getNewsDetail(int id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/News/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'News not found'};
      } else {
        return {'success': false, 'message': 'Failed to load news detail'};
      }
    } catch (e) {
      print('Network error fetching news detail: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getMealPlans() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/MealPlan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load meal plans'};
      }
    } catch (e) {
      print('Network error fetching meal plans: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getHealthRecords(int studentId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/HealthRecords/Student/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load health records'};
      }
    } catch (e) {
      print('Network error fetching health records: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load notifications'};
      }
    } catch (e) {
      print('Network error fetching notifications: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(int id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/Notifications/$id/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to mark notification as read'};
      }
    } catch (e) {
      print('Network error marking notification as read: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/Notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to mark all notifications as read'};
      }
    } catch (e) {
      print('Network error marking all notifications as read: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> getTransactions() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/Transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load transactions'};
      }
    } catch (e) {
      print('Network error fetching transactions: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  Future<Map<String, dynamic>> payTransaction(int id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/Transactions/pay/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to pay transaction'};
      }
    } catch (e) {
      print('Network error paying transaction: $e');
      return {'success': false, 'message': 'Network error ($e). Please try again later.'};
    }
  }

  // --- Clubs Methods ---
  
  Future<Map<String, dynamic>> getClubs() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No authentication token found'};

      final response = await http.get(
        Uri.parse('$baseUrl/api/Clubs'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to load clubs'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<Map<String, dynamic>> getClubDetail(int id) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      final response = await http.get(
        Uri.parse('$baseUrl/api/Clubs/$id'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load club detail'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<Map<String, dynamic>> joinClub(int id) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      final response = await http.post(
        Uri.parse('$baseUrl/api/Clubs/$id/join'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        String msg = 'Failed to join';
        try { msg = jsonDecode(response.body)['message'] ?? msg; } catch(_) {}
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<Map<String, dynamic>> updateClub(int id, String? desc, String? avatarUrl) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      final response = await http.put(
        Uri.parse('$baseUrl/api/Clubs/$id'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'description': desc, 'avatarUrl': avatarUrl}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) return {'success': true};
      return {'success': false, 'message': 'Failed to update club'};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<Map<String, dynamic>> manageClubMember(int clubId, int studentId, String action) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      final response = await http.post(
        Uri.parse('$baseUrl/api/Clubs/$clubId/members/$studentId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'action': action}),
      );

      if (response.statusCode == 200) return {'success': true};
      String msg = 'Failed to manage member';
      try { msg = jsonDecode(response.body)['message'] ?? msg; } catch(_) {}
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<Map<String, dynamic>> createClubEvent(int clubId, String title, String? desc, String? eventDate) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      final response = await http.post(
        Uri.parse('$baseUrl/api/Clubs/$clubId/events'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'title': title, 'description': desc, 'eventDate': eventDate}),
      );

      if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
      String msg = 'Failed to create event';
      try { msg = jsonDecode(response.body)['message'] ?? msg; } catch(_) {}
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<Map<String, dynamic>> updateClubEvent(int clubId, int eventId, String? title, String? desc, String? eventDate) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      final response = await http.put(
        Uri.parse('$baseUrl/api/Clubs/$clubId/events/$eventId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'title': title, 'description': desc, 'eventDate': eventDate}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) return {'success': true};
      return {'success': false, 'message': 'Failed to update event'};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }

  Future<Map<String, dynamic>> deleteClubEvent(int clubId, int eventId) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      final response = await http.delete(
        Uri.parse('$baseUrl/api/Clubs/$clubId/events/$eventId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) return {'success': true};
      return {'success': false, 'message': 'Failed to delete event'};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e)'};
    }
  }
}
