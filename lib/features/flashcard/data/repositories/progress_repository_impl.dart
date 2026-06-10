import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import 'package:bim/features/flashcard/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {

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
  Future<Map<String, dynamic>> getMyProgress(String token, String studentId) async {
    try {
      final id = studentId.isEmpty ? _getStudentIdFromToken(token) : studentId;
      final dynamicUrl = '${ApiConstants.progressEndpoint}?studentId=$id';

      final response = await http.get(
        Uri.parse(dynamicUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['code'] == 200) return data['result'] ?? {};
        throw Exception(data['message'] ?? 'Tải tiến độ học tập thất bại');
      }
      throw Exception('Lỗi kết nối: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi tải tiến độ học tập: $e');
    }
  }

  @override
  Future<List<dynamic>> getMyWeakVocabulary(String token, String studentId, {int? limit}) async {
    try {
      final id = studentId.isEmpty ? _getStudentIdFromToken(token) : studentId;
      String limitParam = limit != null ? '&limit=$limit' : '';
      final dynamicUrl = '${ApiConstants.weakVocabEndpoint}?studentId=$id$limitParam';

      final response = await http.get(
        Uri.parse(dynamicUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['code'] == 200) return data['result'] ?? [];
        throw Exception(data['message'] ?? 'Tải danh sách từ vựng yếu thất bại');
      }
      throw Exception('Lỗi kết nối: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi tải từ vựng yếu: $e');
    }
  }
}