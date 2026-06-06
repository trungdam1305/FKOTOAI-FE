
class ApiConstants {
  static const String baseUrl = 'https://0f510d00-6191-4436-a141-66c5fb3f52a6.mock.pstmn.io';

  //authen
  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String registerEndpoint = '$baseUrl/api/auth/register';
  static const String forgetPasswordEndpoint = '$baseUrl/api/auth/forget-password';
  static const String verifyOtpEndpoint = '$baseUrl/api/auth/verify-otp';
  static const String resetPasswordEndpoint = '$baseUrl/api/auth/reset-password';
  static const String logoutEndpoint = '$baseUrl/api/auth/logout';


  //home
  static const String dashboardEndpoint = '$baseUrl/api/home/dashboard';

  //flashcard
  static const String flashcardEndpoint = '$baseUrl/api/flashcard/learning';
  static const String flashcardCollectionEndpoint = '$baseUrl/api/flashcard/collection';

  //profile
  static const String profileEndpoint = '$baseUrl/api/auth/view-profile';
  static const String updateProfileEndpoint = '$baseUrl/api/auth/update-profile';
}