
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  //login
  @override
  Future<String> login(String identifier, String password) async {
    try {
      final url = Uri.parse(ApiConstants.loginEndpoint);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return data['token'];
        } else {
          throw Exception(data['message'] ?? 'Đăng nhập không thành công');
        }
      } else {
        throw Exception('Lỗi hệ thống: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Mock Server: $e');
    }
  }

  //register
  @override
  Future<String> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.registerEndpoint);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          return data['token']; // Trả về mã token từ Postman Mock
        } else {
          throw Exception(data['message'] ?? 'Đăng ký thất bại');
        }
      } else {
        throw Exception('Lỗi hệ thống: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Mock Server: $e');
    }
  }
}