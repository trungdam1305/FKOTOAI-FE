import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {

  String _getStudentIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '1';

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);

      if (data['id'] != null) return data['id'].toString();
      if (data['userId'] != null) return data['userId'].toString();

      return '1';
    } catch (_) {
      return '1';
    }
  }

  @override
  Future<Map<String, dynamic>> getFlashcards(String token, {int chapterId = 1}) async {
    try {
      final studentId = _getStudentIdFromToken(token);
      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy ID người dùng hợp lệ trong mã xác thực!');
      }

      final dynamicUrl = '${ApiConstants.flashcardByChapterEndpoint}/$chapterId?studentId=$studentId';

      final response = await http.get(
        Uri.parse(dynamicUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 200) return data;
        throw Exception(data['message'] ?? 'Lấy bộ Flashcard thất bại');
      }
      throw Exception('Không thể tải bộ Flashcard (${response.statusCode})');
    } catch (e) {
      throw Exception('Lỗi kết nối hệ thống Flashcard: $e');
    }
  }

  @override
  Future<void> submitCardReview(String token, int flashcardId, String status) async {
    try {
      final studentId = _getStudentIdFromToken(token);
      if (studentId.isEmpty) {
        throw Exception('Không tìm thấy ID người dùng hợp lệ trong mã xác thực!');
      }

      final dynamicUrl = '${ApiConstants.flashcardReviewEndpoint}?studentId=$studentId';

      final response = await http.post(
        Uri.parse(dynamicUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "flashcardId": flashcardId,
          "status": status
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 200) return;
        throw Exception(data['message'] ?? 'Gửi kết quả học tập thất bại');
      }
      throw Exception('Thất bại khi đồng bộ tiến độ (${response.statusCode})');
    } catch (e) {
      throw Exception('Lỗi đánh giá thẻ từ: $e');
    }
  }


}