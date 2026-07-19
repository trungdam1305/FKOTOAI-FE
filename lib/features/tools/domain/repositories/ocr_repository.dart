import 'dart:io';

abstract class OcrRepository {
  Future<List<Map<String, dynamic>>> lookupImage(File imageFile, String token, String studentId);
}