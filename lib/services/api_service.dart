import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 10.0.2.2 is the special local IP for Android Emulator to connect to your PC server.
  // If testing on a physical phone, replace 10.0.2.2 with your PC's Wi-Fi IP (e.g., 192.168.1.50).
  static const String baseUrl = 'http://10.72.23.231:8000/api';

  // --- TOKEN LOCAL STORAGE ---
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sanctum_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sanctum_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sanctum_token');
  }

  // --- 1. REQUEST OTP ---
  static Future<bool> requestOtp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/request-otp'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      debugPrint("OTP Status Code: ${response.statusCode}");
      debugPrint("OTP Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      // THIS WILL TELL YOU THE EXACT NETWORK ERROR
      debugPrint("OTP Network Error: $e");
      return false;
    }
  }

  // --- 2. VERIFY OTP ---
  static Future<Map<String, dynamic>?> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp_code': otpCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await saveToken(token);
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- 3. FETCH NEARBY INCIDENTS ---
  static Future<List<dynamic>> getIncidents(double lat, double lng) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/incidents?latitude=$lat&longitude=$lng'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 4. SUBMIT INCIDENT REPORT WITH MEDIA ---
  static Future<bool> submitIncident({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    File? mediaFile,
  }) async {
    try {
      final token = await getToken();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/incidents'));

      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['category'] = category;
      request.fields['description'] = description;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      if (mediaFile != null) {
        request.files.add(await http.MultipartFile.fromPath('media[]', mediaFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // PRINTS EXACT SERVER STATUS & ERROR REASON TO CONSOLE
      debugPrint("Submit Status Code: ${response.statusCode}");
      debugPrint("Submit Response Body: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Submit Incident Network Exception: $e");
      return false;
    }
  }

  // --- 5. CAST GEOFENCED VOTE ---
  static Future<Map<String, dynamic>> castVote(int incidentId, bool isValid, double lat, double lng) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/incidents/$incidentId/vote'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'is_valid': isValid,
          'latitude': lat,
          'longitude': lng,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Vote processed.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error.'};
    }
  }
}