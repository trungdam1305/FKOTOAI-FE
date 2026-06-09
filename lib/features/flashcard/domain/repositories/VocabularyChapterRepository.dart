abstract class VocabularyChapterRepository {
  Future<Map<String, dynamic>> createChapter(
      String token,
      String studentId,
      String title,
      String desc,
      String level,
      int orderIndex
      );

  Future<List<dynamic>> getMyChapters(String token, String studentId);

  Future<List<dynamic>> getSystemChapters(String token);

  Future<Map<String, dynamic>> getChapterDetail(String token, int chapterId, String studentId);

  Future<void> updateChapter(
      String token,
      int chapterId,
      String studentId,
      String title,
      String desc,
      String level,
      int orderIndex
      );

  Future<void> deleteChapter(String token, int chapterId, String studentId);
}