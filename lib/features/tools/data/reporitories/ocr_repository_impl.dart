import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:bim/core/constants/api_constants.dart';
import '../../domain/repositories/ocr_repository.dart';

class OcrRepositoryImpl implements OcrRepository {

  String _getStudentIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);

      if (data['studentId'] != null) return data['studentId'].toString();
      if (data['studentID'] != null) return data['studentID'].toString();
      if (data['id'] != null) return data['id'].toString();
      if (data['userId'] != null) return data['userId'].toString();

      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> lookupImage(File imageFile, String token, String studentId) async {
    try {
      var finalStudentId = studentId.isNotEmpty ? studentId : _getStudentIdFromToken(token);
      if (finalStudentId.isEmpty) {
        finalStudentId = '3'; // ID test như Postman
      }

      final uri = Uri.parse(ApiConstants.ocrLookupEndpoint);
      final request = http.MultipartRequest('POST', uri);

      request.fields['studentId'] = finalStudentId;


      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = '*/*';


      if (!imageFile.existsSync() || imageFile.lengthSync() == 0) {
        throw Exception('File ảnh không hợp lệ hoặc không tồn tại!');
      }

      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("[OCR Repo] URL: ${uri.toString()}");
      print("[OCR Repo] StudentID in fields: $finalStudentId");
      print("[OCR Repo] Status Code: ${response.statusCode}");
      print("[OCR Repo] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['code'] == 200 && data['result'] != null) {
          final resultData = data['result'];
          if (resultData is Map) {
            return [
              {
                'word': resultData['originalText'] ?? '',
                'meaning': resultData['translatedText'] ?? '',
                'hiragana': '',
                'level': 'OCR'
              }
            ];
          }
        }
        throw Exception(data['message'] ?? 'Nhận diện ảnh thất bại');
      } else {
        try {
          final data = jsonDecode(response.body);
          throw Exception('${data['message'] ?? 'Lỗi hệ thống'} (Mã: ${data['code'] ?? response.statusCode})');
        } catch (_) {
          throw Exception('Lỗi kết nối Server: ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      print("[OCR Repo Error] $e");
      print(stackTrace);
      rethrow;
    }
  }
}
