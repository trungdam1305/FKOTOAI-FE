import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import 'package:bim/features/quiz/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {

  @override
  Future<List<dynamic>> getCourses(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          if (data['code'] == 200 && data['result'] != null) {
            return data['result'] as List<dynamic>;
          } else {
            throw Exception(
              data['message'] ?? 'Lấy danh sách khóa học thất bại!',
            );
          }
        }

        throw Exception('Dữ liệu khóa học từ server trống rỗng!');
      }

      throw Exception(
        'Không thể tải danh sách khóa học (Mã lỗi: ${response.statusCode})',
      );
    } catch (e) {
      throw Exception('Lỗi kết nối hệ thống khóa học: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCourseDetail(
      String token,
      String slug,
      ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/courses/$slug'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          if (data['code'] == 200 && data['result'] != null) {
            return Map<String, dynamic>.from(data['result']);
          } else {
            throw Exception(
              data['message'] ?? 'Lấy chi tiết khóa học thất bại!',
            );
          }
        }

        throw Exception('Dữ liệu khóa học từ server trống rỗng!');
      }

      throw Exception(
        'Không thể tải chi tiết khóa học (Mã lỗi: ${response.statusCode})',
      );
    } catch (e) {
      throw Exception('Lỗi kết nối hệ thống khóa học: $e');
    }
  }
}