
class ApiConstants {
  // static const String baseUrl = 'https://0f510d00-6191-4436-a141-66c5fb3f52a6.mock.pstmn.io';
  static const String baseUrl = 'http://10.0.2.2:8080/FKOTOAI';
  //authen
  static const String loginEndpoint = '$baseUrl/authen/log-in';
  static const String registerEndpoint = '$baseUrl/student';
  static const String forgotPasswordEndpoint = '$baseUrl/authen/forgot-password';
  static const String verifyOtpEndpoint = '$baseUrl/authen/verify-otp';
  static const String resetPasswordEndpoint = '$baseUrl/authen/reset-password';
  static const String logoutEndpoint = '$baseUrl/authen/logout';

  //home
  static String dashboardEndpoint(Object studentId) => '$baseUrl/api/v1/students/$studentId/home';

  //flashcard
  static const String flashcardByChapterEndpoint = '$baseUrl/flashcards/chapters';
  static const String flashcardReviewEndpoint = '$baseUrl/flashcards/review';

  //profile
  static String profileEndpoint(Object studentId) => '$baseUrl/student/$studentId';
  static const String updateProfileEndpoint = '$baseUrl/student/update-profile';

  // Vocabulary Chapter Endpoints
  static const String vocabularyChaptersEndpoint = '$baseUrl/vocabulary-chapters';
  static const String myChaptersEndpoint = '$baseUrl/vocabulary-chapters/my';
  static const String systemChaptersEndpoint = '$baseUrl/vocabulary-chapters/system';

  // Progress Endpoints
  static const String progressEndpoint = '$baseUrl/v1/progress';
  static const String weakVocabEndpoint = '$baseUrl/v1/progress/weak-vocab';

  //Vocab Endpoints
  static const String _vocabItemsBase = '$baseUrl/vocabulary-chapters';
  static String vocabItemsEndpoint(Object chapterId, Object studentId) =>
      '$_vocabItemsBase/$chapterId/items?studentId=$studentId';
  static String vocabItemDetailEndpoint(Object chapterId, Object vocabId, Object studentId) =>
      '$_vocabItemsBase/$chapterId/items/$vocabId?studentId=$studentId';
}