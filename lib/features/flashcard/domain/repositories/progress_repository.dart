abstract class ProgressRepository {

  Future<Map<String, dynamic>> getMyProgress(String token, String studentId);

  Future<List<dynamic>> getMyWeakVocabulary(String token, String studentId, {int? limit});
}