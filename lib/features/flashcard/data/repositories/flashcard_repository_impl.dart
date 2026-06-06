import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {

  @override
  Future<Map<String, dynamic>> getFlashcards(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.flashcardEndpoint),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception('Không thể tải bộ Flashcard (${response.statusCode})');
    } catch (e) { throw Exception('Lỗi kết nối hệ thống: $e'); }
  }

  @override
  Future<List<dynamic>> fetchCollections(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.flashcardCollectionEndpoint),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        return responseData is List ? responseData : (responseData['collections'] ?? responseData['folders'] ?? []);
      }
      throw Exception('Lỗi tải danh sách bộ học phần (${response.statusCode})');
    } catch (e) { throw Exception('Lỗi kết nối: $e'); }
  }

  @override
  Future<void> createCollection(String token, String title, String desc) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.flashcardCollectionEndpoint),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({"title": title, "description": desc, "flashcards": []}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception('Thất bại');
    } catch (e) { throw Exception('Lỗi tạo bộ học phần: $e'); }
  }

  @override
  Future<void> updateCollection(String token, String id, String title, String desc) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.flashcardCollectionEndpoint}/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({"title": title, "description": desc}),
      );
      if (response.statusCode != 200) throw Exception('Thất bại');
    } catch (e) { throw Exception('Lỗi cập nhật bộ học phần: $e'); }
  }

  @override
  Future<void> deleteCollection(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.flashcardCollectionEndpoint}/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) throw Exception('Thất bại');
    } catch (e) { throw Exception('Lỗi xóa bộ học phần: $e'); }
  }

  @override
  Future<void> addCard(String token, String folderId, Map<String, String> cardData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.flashcardCollectionEndpoint}/$folderId/cards'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(cardData),
      );
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception('Thất bại');
    } catch (e) { throw Exception('Lỗi thêm thẻ từ: $e'); }
  }

  @override
  Future<void> updateCard(String token, String folderId, String cardId, Map<String, String> cardData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.flashcardCollectionEndpoint}/$folderId/cards/$cardId'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(cardData),
      );
      if (response.statusCode != 200) throw Exception('Thất bại');
    } catch (e) { throw Exception('Lỗi sửa thẻ từ: $e'); }
  }

  @override
  Future<void> deleteCard(String token, String folderId, String cardId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.flashcardCollectionEndpoint}/$folderId/cards/$cardId'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) throw Exception('Thất bại');
    } catch (e) { throw Exception('Lỗi xóa thẻ từ: $e'); }
  }
}