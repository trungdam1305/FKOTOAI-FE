import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {

  String _getStudentIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '1';

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);

      return (data['id'] ?? data['userId'] ?? data['sub'] ?? '1').toString();
    } catch (_) {
      return '1';
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardData(String token) async {
    try {
      final studentId = _getStudentIdFromToken(token);

      final dynamicUrl = '${ApiConstants.baseUrl}/api/v1/students/$studentId/home';

      final response = await http.get(
        Uri.parse(dynamicUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Không thể tải dữ liệu (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối hệ thống: $e');
    }
  }
}