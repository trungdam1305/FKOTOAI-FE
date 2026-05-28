// lib/features/authentication/presentation/auth_controller.dart
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController {
  final AuthRepository _repository;
  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl();
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
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String initialLevel,
    required Function() onLoading,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    try {
      await _repository.register(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
        initialLevel: initialLevel,
      );
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }


  Future<void> loginWithGoogle({
    required Function() onLoading,
    required Function(String token) onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    try {

      await Future.delayed(const Duration(milliseconds: 1500));


      final mockGoogleToken = "mock_google_oauth_token_xyz_98765";
      onSuccess(mockGoogleToken);
    } catch (e) {
      onError("Đăng nhập bằng Google thất bại. Vui lòng thử lại!");
    }
  }


  //forget password
  // 1. Gửi yêu cầu mã OTP qua Email
  Future<void> sendPasswordResetOTP({
    required String email,
    required Function() onLoading,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    try {
      await _repository.sendForgotPasswordOTP(email);
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 2. Xác thực mã OTP
  Future<void> verifyResetOTP({
    required String email,
    required String otp,
    required Function() onLoading,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    try {
      await _repository.verifyOTP(email, otp);
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 3. Tạo mật khẩu mới (Confirm Reset)
  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
    required Function() onLoading,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    try {
      await _repository.resetPassword(email, otp, newPassword);
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}