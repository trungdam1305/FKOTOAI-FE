abstract class FlashcardRepository {

  Future<Map<String, dynamic>> getFlashcards(String token, {int chapterId = 1});

  Future<void> submitCardReview(String token, int flashcardId, String status);

  // CRUD Vocabulary Items
  Future<Map<String, dynamic>> addVocabToChapter(
      String token, int chapterId, String word, String meaning);

  Future<List<dynamic>> getVocabsInChapter(String token, int chapterId);

  Future<void> updateVocabInChapter(
      String token, int chapterId, int vocabId, String word, String meaning);

  Future<void> removeVocabFromChapter(
      String token, int chapterId, int vocabId);
}