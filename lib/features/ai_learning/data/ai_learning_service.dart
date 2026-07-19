import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:flutter/foundation.dart';

class AiLearningService {
  final String baseUrl = 'http://10.0.2.2:8080/FKOTOAI';
  final AuthLocalDataSource _auth = AuthLocalDataSource();

  Future<Map<String, String>> _getHeaders(String studentId) async {
    final token = await _auth.getToken();
    debugPrint('DEBUG studentId = "$studentId"');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Student-Id': studentId,
    };
  }

  Future<Map<String, dynamic>> generateChallenge(String studentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/challenge/generate'),
      headers: await _getHeaders(studentId),
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> submitChallenge(String studentId, int sessionId, List<Map<String, dynamic>> answers) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/challenge/submit'),
      headers: await _getHeaders(studentId),
      body: json.encode({'sessionId': sessionId, 'answers': answers}),
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> chatWithAi(String studentId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/chat'),
      headers: await _getHeaders(studentId),
      body: json.encode({'message': message}),
    );
    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    if (data['code'] == 8386) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Lỗi hệ thống AI');
    }
  }
}