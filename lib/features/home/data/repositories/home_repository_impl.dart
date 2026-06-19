import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {

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
  Future<Map<String, dynamic>> getDashboardData(String token) async {
    try {
      final studentId = _getStudentIdFromToken(token);

      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy ID người dùng hợp lệ trong mã xác thực!');
      }

      final dynamicUrl = '${ApiConstants.baseUrl}/api/v1/students/$studentId/home';

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

          if (data['code'] == 8386 && data['result'] != null) {
            return data['result'] as Map<String, dynamic>;
          } else {
            throw Exception(data['message'] ?? 'Lấy dữ liệu trang chủ thất bại!');
          }
        }
        throw Exception('Dữ liệu trang chủ trả về từ máy chủ trống rỗng!');
      } else {
        throw Exception('Không thể tải dữ liệu trang chủ (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối hệ thống trang chủ: $e');
    }
  }
}