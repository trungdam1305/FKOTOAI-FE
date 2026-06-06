import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  @override
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    // 1. Lấy url từ ApiConstants chung của cậu (Giống hệt cách gọi bên Auth)
    // Cậu nhớ thêm `static const String profileEndpoint = '$baseUrl/api/profile';` vào file api_constants.dart nhé!
    final url = Uri.parse(ApiConstants.profileEndpoint);

    // 2. Gọi HTTP GET trực tiếp ở đây kèm Token Authorization
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // 3. Xử lý bóc tách dữ liệu Map<String, dynamic> trần trụi
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);

          // Hỗ trợ bóc tách linh hoạt: nếu backend bọc trong key 'data' thì lấy, không thì lấy cả cục
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