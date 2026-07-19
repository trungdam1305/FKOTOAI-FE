import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import 'package:bim/features/quiz/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {

  String _getStudentIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);
      if (data['studentID'] != null) return data['studentID'].toString();
      if (data['id'] != null) return data['id'].toString();
      if (data['userId'] != null) return data['userId'].toString();
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<List<dynamic>> getCourses(String token) async {
    try {
      final studentId = _getStudentIdFromToken(token);
      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy ID người dùng hợp lệ trong mã xác thực!');
      }

      final dynamicUrl = '${ApiConstants.baseUrl}/api/v1/courses';

      final response = await http.get(
        Uri.parse(dynamicUrl),
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
            throw Exception(data['message'] ?? 'Lấy danh sách khóa học thất bại!');
          }
        }
        throw Exception('Dữ liệu khóa học từ server trống rỗng!');
      } else {
        throw Exception('Không thể tải danh sách khóa học (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối hệ thống khóa học: $e');
    }
  }
}