import 'package:flutter/material.dart';
import 'package:bim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:bim/features/authentication/presentation/screens/login_screen.dart';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/app_text_styles.dart';
import 'package:bim/core/theme/gradient_background.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/subscription_package.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

// THÊM WidgetsBindingObserver ĐỂ LẮNG NGHE KHI USER QUAY LẠI APP
class _ProfileTabState extends State<ProfileTab> with WidgetsBindingObserver {
  final ProfileController _controller = ProfileController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Đăng ký lắng nghe vòng đời app
    _controller.loadProfileData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Hủy lắng nghe khi thoát tab
    super.dispose();
  }

  // HÀM NÀY SẼ CHẠY TỰ ĐỘNG KHI BẠN TỪ TRÌNH DUYỆT VNPAY QUAY TRỞ LẠI APP
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("App được mở lại -> Tự động cập nhật Profile để lấy số ngày Premium...");
      _controller.loadProfileData();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () async {
              Navigator.pop(context);
              await _controller.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.profile == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (_controller.errorMessage.isNotEmpty && _controller.profile == null) {
            return Center(child: Text(_controller.errorMessage, style: const TextStyle(color: Colors.red)));
          }

          final p = _controller.profile;
          if (p == null) return const Center(child: Text('Không có dữ liệu'));

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(p['avatarUrl'] ?? 'https://placeholder.com/user.png'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Text(p['fullname'] ?? 'Học viên', style: AppTextStyles.heading1),
                      Text(p['email'] ?? '', style: AppTextStyles.bodyNormal.copyWith(color: Colors.grey)),
                      const SizedBox(height: 24),
                      _buildStatsRow(p),
                      const SizedBox(height: 32),
                      _buildOverviewCard(p),
                      const SizedBox(height: 24),
                      _buildPremiumCard(context, p),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String avatarUrl) {
    return Container(
      width: double.infinity, height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 40, right: 16, child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.blueAccent, size: 26),
            onPressed: _showLogoutDialog,
          )),
          Positioned(bottom: 0, child: Container(
            width: 110, height: 110,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
            child: ClipOval(child: Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50))),
          )),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _statCol('🔥', '${p['streakCount'] ?? 0} Ngày', 'Chuỗi liên tục'),
        Container(width: 1.5, height: 40, color: Colors.grey.shade300),
        _statCol('⚡', '${p['rankPoints'] ?? 1000}', 'Điểm hạng'),
      ]),
    );
  }

  Widget _statCol(String emoji, String count, String label) => Column(children: [
    Row(children: [Text(emoji), const SizedBox(width: 4), Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary))]),
    Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
  ]);

  Widget _buildOverviewCard(Map<String, dynamic> p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        const Text('🛡️', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p['currentLevel'] ?? 'N5', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const Text('Trình độ hiện tại', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ]),
    );
  }

  Widget _buildPremiumCard(BuildContext context, Map<String, dynamic> p) {
    bool isPremiumActive = false;
    int daysLeft = 0;

    final expiryString = p['quizSubscriptionExpiry'] ?? p['quiz_subscription_expiry'];

    if (expiryString != null) {
      try {
        final expiryDate = DateTime.parse(expiryString);
        final now = DateTime.now();

        if (expiryDate.isAfter(now)) {
          isPremiumActive = true;
          daysLeft = expiryDate.difference(now).inDays;
          if (daysLeft == 0) daysLeft = 1;
        }
      } catch (e) {
        debugPrint('Lỗi parse ngày hết hạn: $e');
      }
    }

    if (isPremiumActive) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2B32B2), Color(0xFF1488CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            const Text('💎', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thành viên Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Đã mở khóa toàn bộ tính năng\nCòn lại $daysLeft ngày', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),
            InkWell(
              onTap: () => _showSubscriptionBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Gia hạn', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _showSubscriptionBottomSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF7971E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Nâng cấp Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Mở khóa toàn bộ bài giảng & bài tập', style: TextStyle(fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('Chọn gói Premium', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: FutureBuilder<List<SubscriptionPackage>>(
                  future: _controller.fetchSubscriptionPackages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không tải được danh sách gói. Vui lòng thử lại.', style: TextStyle(color: Colors.red)));
                    }
                    final packages = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: packages.length,
                      itemBuilder: (context, index) => _buildPackageOption(packages[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageOption(SubscriptionPackage pkg) {
    bool isPopular = pkg.packageCode == 'YEARLY' || pkg.packageName.toLowerCase().contains('năm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: isPopular ? Colors.orange : Colors.grey.shade300, width: isPopular ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
        color: isPopular ? Colors.orange.shade50 : Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(pkg.packageName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                        child: const Text('HOT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 6),
                Text(pkg.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              backgroundColor: isPopular ? Colors.orange : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _handlePayment(pkg.packageId);
            },
            child: Text('${pkg.price.toInt()}đ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(int packageId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final paymentUrl = await _controller.createPaymentUrl(packageId);
      if (mounted) Navigator.pop(context);

      if (paymentUrl != null) {
        final uri = Uri.parse(paymentUrl);
        try {
          // THAY ĐỔI: Dùng inAppBrowserView để mở WebView ngay bên trong App
          await launchUrl(
            uri,
            mode: LaunchMode.inAppBrowserView, // Giữ user trong app
          );
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy trình duyệt!')));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}