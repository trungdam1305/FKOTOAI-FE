import '../../domain/models/subscription_package.dart';
abstract class ProfileRepository {
  Future<Map<String, dynamic>> getUserProfile(String token);
  Future<List<SubscriptionPackage>> getSubscriptionPackages(String token); // Thêm dòng này
}