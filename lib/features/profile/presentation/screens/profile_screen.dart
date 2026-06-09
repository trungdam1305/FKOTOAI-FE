import 'package:flutter/material.dart';
import 'package:bim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:bim/features/authentication/presentation/screens/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ProfileController _controller = ProfileController();

  final Color primaryBlue = const Color(0xFF3B40E8);
  final Color textBlack = const Color(0xFF2D2D2D);
  final Color textGrey = const Color(0xFF757575);
  final Color borderColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _controller.loadProfileData();
  }

  TextStyle _txt({double size = 14, FontWeight weight = FontWeight.w600, bool isGrey = false}) {
    return TextStyle(fontSize: size, fontWeight: weight, color: isGrey ? textGrey : textBlack, fontFamily: 'Nunito');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }

        if (_controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(_controller.errorMessage, style: _txt(), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  child: const Text('Đăng nhập lại'),
                ),
              ],
            ),
          );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(child: Text(p['fullname'] ?? 'Học viên', style: _txt(size: 24, weight: FontWeight.w900))),
                    const SizedBox(height: 4),
                    Center(child: Text(p['email'] ?? '', style: _txt(isGrey: true))),
                    const SizedBox(height: 24),
                    _buildStatsRow(p),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Thông tin học tập', Icons.bar_chart_rounded, Colors.purple.shade400),
                    const SizedBox(height: 16),
                    _buildOverviewGrid(p),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String avatarUrl) {
    return Container(
      width: double.infinity, height: 180, color: const Color(0xFFF8F9FA),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40, right: 16,
            child: IconButton(icon: Icon(Icons.settings_outlined, color: textGrey, size: 26), onPressed: () {}),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: borderColor, width: 3)),
              child: ClipOval(
                child: Image.network(
                  avatarUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 50, color: textGrey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> p) {
    Widget statCol(String emoji, String count, String label) => Column(
      children: [
        Row(children: [Text(emoji), const SizedBox(width: 4), Text(count, style: _txt(size: 18, weight: FontWeight.w800))]),
        const SizedBox(height: 4),
        Text(label, style: _txt(size: 12, isGrey: true)),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          statCol('🔥', '${p['streakCount'] ?? 0} Ngày', 'Chuỗi liên tục'),
          Container(width: 1.5, height: 40, color: borderColor),
          statCol('⚡', '${p['rankPoints'] ?? 1000}', 'Điểm hạng'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 22, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito', letterSpacing: 0.3)),
      ],
    );
  }

  Widget _buildOverviewGrid(Map<String, dynamic> p) {
    Widget card(String icon, String title, String subtitle) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: 2)),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: _txt(size: 17, weight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: _txt(size: 12, isGrey: true), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );

    return GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.8,
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      children: [
        card('🛡️', p['currentLevel'] ?? 'N5', 'Trình độ hiện tại'),
        card('🆔', '${p['studentId'] ?? ''}', 'Mã số học viên'),
      ],
    );
  }
}