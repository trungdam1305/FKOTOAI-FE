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

  // --- CRUD Vocabulary Chapter Items ---

  // 1. POST
  @override
  Future<Map<String, dynamic>> addVocabToChapter(String token, int chapterId, String word, String meaning) async {
    final studentId = _getStudentIdFromToken(token);
    final url = Uri.parse(ApiConstants.vocabItemsEndpoint(chapterId, studentId));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "word": word,
        "meaning": meaning,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Thêm từ vựng thất bại (${response.statusCode})');
  }

  // 2. GET
  @override
  Future<List<dynamic>> getVocabsInChapter(String token, int chapterId) async {
    final studentId = _getStudentIdFromToken(token);
    final url = Uri.parse(ApiConstants.vocabItemsEndpoint(chapterId, studentId));

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('result')) {
        return (decoded['result'] as List<dynamic>?) ?? [];
      }
      return [];
    }
    throw Exception('Lấy danh sách từ vựng thất bại (${response.statusCode})');
  }

  // 3. PUT
  @override
  Future<void> updateVocabInChapter(String token, int chapterId, int vocabId, String word, String meaning) async {
    final studentId = _getStudentIdFromToken(token);
    final url = Uri.parse(ApiConstants.vocabItemDetailEndpoint(chapterId, vocabId, studentId));

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "word": word,
        "meaning": meaning,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật từ vựng thất bại');
    }
  }

  //delete
  @override
  Future<void> removeVocabFromChapter(String token, int chapterId, int vocabId) async {
    final studentId = _getStudentIdFromToken(token);
    final url = Uri.parse(ApiConstants.vocabItemDetailEndpoint(chapterId, vocabId, studentId));

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}