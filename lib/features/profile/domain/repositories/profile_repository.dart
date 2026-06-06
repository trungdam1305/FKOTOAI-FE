abstract class ProfileRepository {
  Future<Map<String, dynamic>> getUserProfile(String token);
}