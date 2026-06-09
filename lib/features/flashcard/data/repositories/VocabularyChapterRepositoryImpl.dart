import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import 'package:bim/features/flashcard/domain/repositories/VocabularyChapterRepository.dart';

class VocabularyChapterRepositoryImpl implements VocabularyChapterRepository {

  String _getStudentIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '1';
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);

      if (data['id'] != null) return data['id'].toString();
      return '1';
    } catch (_) {
      return '1';
    }
  }

  // POST
  @override
  Future<Map<String, dynamic>> createChapter(
      String token,
      String studentId,
      String title,
      String desc,
      String level,
      int orderIndex
      ) async {
    try {
      final id = studentId.isEmpty ? _getStudentIdFromToken(token) : studentId;
      final dynamicUrl = '${ApiConstants.vocabularyChaptersEndpoint}?studentId=$id';

      final response = await http.post(
        Uri.parse(dynamicUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "chapterName": title,
          "level": level,
          "orderIndex": orderIndex,
          "description": desc
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 201 || data['code'] == 200) return data['result'];
        throw Exception(data['message'] ?? 'Tạo chương thất bại');
      }
      throw Exception('Lỗi máy chủ: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi tạo chương học: $e');
    }
  }

  @override
  Future<List<dynamic>> getMyChapters(String token, String studentId) async {
    try {
      final id = studentId.isEmpty ? _getStudentIdFromToken(token) : studentId;
      final dynamicUrl = '${ApiConstants.myChaptersEndpoint}?studentId=$id';

      final response = await http.get(
        Uri.parse(dynamicUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 200) return data['result'] ?? [];
        throw Exception(data['message'] ?? 'Tải danh sách thất bại');
      }
      throw Exception('Lỗi kết nối: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi tải chương cá nhân: $e');
    }
  }

  @override
  Future<List<dynamic>> getSystemChapters(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.systemChaptersEndpoint),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 200) return data['result'] ?? [];
        throw Exception(data['message'] ?? 'Tải danh sách hệ thống thất bại');
      }
      throw Exception('Lỗi kết nối hệ thống: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi tải chương hệ thống: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getChapterDetail(String token, int chapterId, String studentId) async {
    try {
      final id = studentId.isEmpty ? _getStudentIdFromToken(token) : studentId;
      final dynamicUrl = '${ApiConstants.vocabularyChaptersEndpoint}/$chapterId?studentId=$id';

      final response = await http.get(
        Uri.parse(dynamicUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 200) return data['result'];
        throw Exception(data['message'] ?? 'Tải chi tiết chương thất bại');
      }
      throw Exception('Lỗi kết nối: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết chương: $e');
    }
  }

  // PUT
  @override
  Future<void> updateChapter(
      String token,
      int chapterId,
      String studentId,
      String title,
      String desc,
      String level,
      int orderIndex
      ) async {
    try {
      final id = studentId.isEmpty ? _getStudentIdFromToken(token) : studentId;
      final dynamicUrl = '${ApiConstants.vocabularyChaptersEndpoint}/$chapterId?studentId=$id';

      final response = await http.put(
        Uri.parse(dynamicUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "chapterName": title,
          "level": level,
          "orderIndex": orderIndex,
          "description": desc
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 200) return;
        throw Exception(data['message'] ?? 'Cập nhật thất bại');
      }
      throw Exception('Lỗi cập nhật: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi sửa thông tin chương: $e');
    }
  }

  // DELETE
  @override
  Future<void> deleteChapter(String token, int chapterId, String studentId) async {
    try {
      final id = studentId.isEmpty ? _getStudentIdFromToken(token) : studentId;
      final dynamicUrl = '${ApiConstants.vocabularyChaptersEndpoint}/$chapterId?studentId=$id';

      final response = await http.delete(
        Uri.parse(dynamicUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 200) return;
        throw Exception(data['message'] ?? 'Xóa thất bại');
      }
      throw Exception('Lỗi xóa: ${response.statusCode}');
    } catch (e) {
      throw Exception('Lỗi xóa chương học: $e');
    }
  }
}