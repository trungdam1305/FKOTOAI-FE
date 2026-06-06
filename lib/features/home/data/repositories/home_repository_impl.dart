import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Map<String, dynamic>> getDashboardData(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.dashboardEndpoint),
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