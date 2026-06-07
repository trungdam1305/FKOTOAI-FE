import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  @override
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final url = Uri.parse(ApiConstants.profileEndpoint);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);

          return (data['data'] ?? data) as Map<String, dynamic>;
        } catch (_) {
          throw Exception('Lỗi định dạng dữ liệu hồ sơ từ hệ thống!');
        }
      }
      throw Exception('Dữ liệu hồ sơ trả về từ máy chủ trống rỗng!');
    } else {
      throw Exception('Không thể tải thông tin hồ sơ cá nhân!');
    }
  }
}