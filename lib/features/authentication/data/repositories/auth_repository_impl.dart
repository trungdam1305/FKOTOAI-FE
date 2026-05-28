
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  //login
  @override
  Future<String> login(String email, String password) async {
    final url = Uri.parse(ApiConstants.loginEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );


    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          return data['token'] ?? 'mock_jwt_token_for_login_12345';
        } catch (_) {
          return 'mock_jwt_token_for_login_12345';
        }
      }

      // Trường hợp Postman trả về Body trống rỗng
      return 'mock_jwt_token_for_login_12345';
    } else {
      throw Exception('Tài khoản hoặc mật khẩu không chính xác!');
    }
  }

  //register
  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String initialLevel,
  }) async {
    final url = Uri.parse(ApiConstants.registerEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'username': username,
        'password': password,
        'initialLevel': initialLevel,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return;

      try {
        final data = jsonDecode(response.body);
        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Đăng ký không thành công!');
        }
      } catch (_) {
        return;
      }
    } else {
      throw Exception('Đăng ký thất bại. Vui lòng thử lại sau!');
    }
  }

  //forget password
  @override
  Future<void> sendForgotPasswordOTP(String email) async {
    final url = Uri.parse('https://0f510d00-6191-4436-a141-66c5fb3f52a6.mock.pstmn.io/api/auth/forget-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể gửi mã OTP. Vui lòng kiểm tra lại email!');
    }
  }

  @override
  Future<void> verifyOTP(String email, String otp) async {
    final url = Uri.parse('https://0f510d00-6191-4436-a141-66c5fb3f52a6.mock.pstmn.io/api/auth/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Mã xác thực OTP không chính xác hoặc đã hết hạn!');
    }
  }

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final url = Uri.parse('https://0f510d00-6191-4436-a141-66c5fb3f52a6.mock.pstmn.io/api/auth/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Đặt lại mật khẩu thất bại. Vui lòng thử lại sau!');
    }
  }

  @override
  Future<void> logout() async {
    final url = Uri.parse('https://0f510d00-6191-4436-a141-66c5fb3f52a6.mock.pstmn.io/api/auth/logout');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return;

      final data = jsonDecode(response.body);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Đăng xuất thất bại!');
      }
    } else {
      throw Exception('Không thể kết nối đến máy chủ để đăng xuất!');
    }
  }
}