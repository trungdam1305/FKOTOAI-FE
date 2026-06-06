abstract class FlashcardRepository {

  Future<Map<String, dynamic>> getFlashcards(String token);

  Future<List<dynamic>> fetchCollections(String token);

  Future<void> createCollection(String token, String title, String desc);

  Future<void> updateCollection(String token, String id, String title, String desc);

  Future<void> deleteCollection(String token, String id);

  Future<void> addCard(String token, String folderId, Map<String, String> cardData);

  Future<void> updateCard(String token, String folderId, String cardId, Map<String, String> cardData);

  Future<void> deleteCard(String token, String folderId, String cardId);
}