import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/models/subscription_package.dart';
class ProfileRepositoryImpl implements ProfileRepository {

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
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final studentId = _getStudentIdFromToken(token);

      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy ID người dùng hợp lệ trong mã xác thực!');
      }

      final dynamicUrl = ApiConstants.profileEndpoint(studentId);

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
            throw Exception(data['message'] ?? 'Lấy thông tin hồ sơ thất bại!');
          }
        }
        throw Exception('Dữ liệu hồ sơ trả về từ máy chủ trống rỗng!');
      } else {
        throw Exception('Không thể tải thông tin hồ sơ cá nhân (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối hệ thống hồ sơ: $e');
    }
  }
  @override
  Future<List<SubscriptionPackage>> getSubscriptionPackages(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/subscription/packages'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => SubscriptionPackage.fromJson(json)).toList();
    } else {
      throw Exception('Không thể tải danh sách gói cước');
    }
  }

}