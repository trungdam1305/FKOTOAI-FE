
abstract class AuthRepository {
  Future<String> login(String identifier, String password);

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String initialLevel,
  });

  //forget password
  Future<void> sendForgotPasswordOTP(String email);
  Future<void> verifyOTP(String email, String otp);
  Future<void> resetPassword(String email, String otp, String newPassword);

  //logout

}
