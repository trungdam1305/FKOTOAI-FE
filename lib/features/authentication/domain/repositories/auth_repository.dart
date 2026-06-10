
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
  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword);
  Future<String> verifyOTP(String email, String otp);


  //logout
  Future<void> logout(String token);
}
