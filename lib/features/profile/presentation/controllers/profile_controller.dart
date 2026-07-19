import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:bim/features/profile/domain/repositories/profile_repository.dart';
import 'package:bim/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:flutter/foundation.dart'; // Để sử dụng debugPrint
import '../../domain/models/subscription_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Đổi thành IP Backend thực tế của bạn (10.0.2.2 nếu dùng máy ảo Android)
const String baseUrl = 'http://10.0.2.2:8080/FKOTOAI';

class ProfileController extends ChangeNotifier {
  // 1. Khai báo các dependency
  final ProfileRepository _repository;
  final AuthLocalDataSource _localDataSource;

  // 2. Constructor Injection
  ProfileController({
    ProfileRepository? repository,
    AuthLocalDataSource? localDataSource,
  })  : _repository = repository ?? ProfileRepositoryImpl(),
        _localDataSource = localDataSource ?? AuthLocalDataSource();

  // Các biến quản lý trạng thái giao diện
  Map<String, dynamic>? profile;
  bool isLoading = false;
  String errorMessage = '';

  // Dùng chung 1 list kiểu chuẩn từ Model của bạn
  List<SubscriptionPackage> packages = [];

  // ==========================================
  // PHẦN 1: QUẢN LÝ PROFILE & AUTH
  // ==========================================

  // Hàm tải dữ liệu người dùng
  Future<void> loadProfileData() async {
    debugPrint("=== loadProfileData ===");
    _setLoadingState(true);

    try {
      final token = await _localDataSource.getToken();
      debugPrint("Token: $token");

      if (token == null || token.isEmpty) {
        throw Exception("Token rỗng");
      }

      final data = await _repository.getUserProfile(token);
      debugPrint("Profile Data: $data");

      profile = data;
    } catch (e) {
      debugPrint("Load Profile Error: $e");
      errorMessage = e.toString().replaceAll("Exception: ", "");
      profile = null;
    } finally {
      _setLoadingState(false);
    }
  }

  // Hàm Đăng xuất
  Future<void> logout() async {
    try {
      await _localDataSource.deleteToken();
      profile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi đăng xuất: $e');
    }
  }

  // Hàm private hỗ trợ cập nhật trạng thái loading
  void _setLoadingState(bool state) {
    isLoading = state;
    if (state) errorMessage = '';
    notifyListeners();
  }

  // ==========================================
  // PHẦN 2: THANH TOÁN & GÓI PREMIUM (VNPAY)
  // ==========================================

  // Hàm tải danh sách gói cước (Dùng cho FutureBuilder ở BottomSheet)
  Future<List<SubscriptionPackage>> fetchSubscriptionPackages() async {
    try {
      final token = await _localDataSource.getToken();
      final studentId = _getRealStudentId(); // Lấy ID thật KHÔNG HARDCODE

      if (studentId == null) {
        debugPrint("❌ Lỗi: Không lấy được ID. Dữ liệu profile hiện tại: $profile");
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/payment/packages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Student-Id': studentId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['code'] == 8386) {
          final List listData = data['result'];
          packages = listData.map((e) => SubscriptionPackage.fromJson(e)).toList();
          notifyListeners();
          return packages;
        }
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi Exception tải gói: $e");
      return [];
    }
  }
  int? _getRealStudentId() {
    // Ưu tiên 1: Thử lấy từ SharedPreferences (nếu lúc Login bạn có lưu)
    // Ưu tiên 2: Lấy trực tiếp từ JSON Profile do Backend trả về
    dynamic rawId = profile?['studentId'] ?? profile?['student_id'] ?? profile?['id'];

    if (rawId != null) {
      return int.tryParse(rawId.toString());
    }
    return null;
  }
  // Hàm tạo URL thanh toán VNPay
  Future<String?> createPaymentUrl(int packageId) async {
    try {
      debugPrint("\n========== TẠO LINK VNPAY ==========");
      final token = await _localDataSource.getToken();

      final studentId = _getRealStudentId(); // Lấy ID thật KHÔNG HARDCODE

      if (studentId == null) {
        debugPrint("❌ Lỗi: Không tìm thấy ID. Dữ liệu profile từ DB là: $profile");
        throw Exception('Không lấy được ID học viên. Vui lòng thoát app và đăng nhập lại.');
      }

      debugPrint("Đang gửi yêu cầu mua PackageID: $packageId");
      debugPrint("👤 VỚI STUDENT_ID THẬT TỪ DATABASE: $studentId");

      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Student-Id': studentId.toString(),
        },
        body: json.encode({
          'packageId': packageId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 8386) {
          final paymentUrl = data['result']['paymentUrl'];
          debugPrint("✅ Lấy link VNPay THÀNH CÔNG: $paymentUrl");
          return paymentUrl;
        } else {
          // Bắn lỗi 400 (như lỗi "You still have an active subscription" ban nãy)
          throw Exception(data['message']);
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message']);
      } else {
        throw Exception('Lỗi kết nối máy chủ (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Lỗi Exception: $e');
      rethrow; // Ném ngược lỗi này ra ngoài cho giao diện hiển thị
    }
  }
}