
abstract class AuthRepository {
  Future<String> login(String identifier, String password);

  Future<String> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  });
}