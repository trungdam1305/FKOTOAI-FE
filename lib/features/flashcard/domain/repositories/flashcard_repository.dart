abstract class FlashcardRepository {

  Future<Map<String, dynamic>> getFlashcards(String token, {int chapterId = 1});

  Future<void> submitCardReview(String token, int flashcardId, String status);
}