import 'package:flutter/material.dart';
import 'package:bim/features/profile/domain/repositories/profile_repository.dart';
import 'package:bim/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepositoryImpl();
  final AuthLocalDataSource _localDataSource = AuthLocalDataSource();

  Map<String, dynamic>? profile;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadProfileData() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Tự đọc token từ Keychain/Keystore ra ở đây
      final token = await _localDataSource.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Phiên đăng nhập đã hết hạn!');
      }

      profile = await _repository.getUserProfile(token);
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}