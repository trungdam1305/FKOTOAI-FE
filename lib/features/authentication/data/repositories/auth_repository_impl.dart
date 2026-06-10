
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
class AuthRepositoryImpl implements AuthRepository {

  final AuthLocalDataSource _localDataSource = AuthLocalDataSource();

  //login
  @override
  Future<String> login(String email, String password) async {
    final url = Uri.parse(ApiConstants.loginEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'passwordHash': password,
      }),
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);

          if (data['code'] == 8386 && data['result'] != null) {
            String token = data['result']['token'];

            await _localDataSource.saveToken(token);
            return token;
          }
        } catch (e) {
          throw Exception('Lỗi xử lý dữ liệu hệ thống: $e');
        }
      }
      throw Exception('Tài khoản hoặc mật khẩu không chính xác!');
    } else {
      throw Exception('Tài khoản hoặc mật khẩu không chính xác!');
    }
  }

// register
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
        'fullname': fullName,
        'email': email,
        'username': username,
        'passwordHash': password,
        'currentLevel': initialLevel,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return;

      try {
        final data = jsonDecode(response.body);

        if (data['code'] != 8386) {
          throw Exception(data['message'] ?? 'Đăng ký không thành công!');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Lỗi xử lý dữ liệu hệ thống!');
      }
    } else {
      throw Exception('Đăng ký thất bại. Vui lòng thử lại sau!');
    }
  }

  //forget password
  @override
  Future<void> sendForgotPasswordOTP(String email) async {
    final url = Uri.parse(ApiConstants.forgotPasswordEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể gửi mã OTP. Vui lòng kiểm tra lại email!');
    }
  }

  //VERIFY OTP
  @override
  Future<String> verifyOTP(String email, String otp) async {
    final url = Uri.parse(ApiConstants.verifyOtpEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 8386 && data['result'] != null) {
        return data['result']['resetToken'];
      }
      throw Exception('Không nhận được mã xác thực từ server!');
    } else {
      throw Exception('Mã xác thực OTP không chính xác hoặc đã hết hạn!');
    }
  }


  //RESET PASS
  @override
  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    final url = Uri.parse(ApiConstants.resetPasswordEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Đặt lại mật khẩu thất bại. Vui lòng thử lại sau!');
    }
  }

  Future<void> logout(String token) async {
    final url = Uri.parse(ApiConstants.logoutEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"token": token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Đăng xuất thất bại: ${response.body}');
    }
  }
}