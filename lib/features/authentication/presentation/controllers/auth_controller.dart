// lib/features/authentication/presentation/auth_controller.dart
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController {

  //login
  final AuthRepository _authRepository = AuthRepositoryImpl();

  Future<void> login({
    required String email,
    required String password,
    required Function() onLoading,
    required Function(String token) onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();

    try {
      final token = await _authRepository.login(email, password);

      onSuccess(token);
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  //register
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required Function() onLoading,
    required Function(String token) onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    try {
      final token = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );
      onSuccess(token);
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}