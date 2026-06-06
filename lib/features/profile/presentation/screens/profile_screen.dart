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
  // final String _token = "dummy_user_token";

  final Color primaryBlue = const Color(0xFF3B40E8);
  final Color textBlack = const Color(0xFF2D2D2D);
  final Color textGrey = const Color(0xFF757575);
  final Color borderColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    //_controller.loadProfileData(_token);
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
                Text(_controller.errorMessage, style: _txt(), textAlign: TextAlign.center),
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

        final stepsLeft = p['stepsLeftToComplete'] ?? 0;

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
                    Center(child: Text(p['fullName'] ?? '', style: _txt(size: 24, weight: FontWeight.w900))),
                    const SizedBox(height: 4),
                    Center(child: Text('${p['username'] ?? ''} • Tham gia ${p['joinedDate'] ?? ''}', style: _txt(isGrey: true))),
                    const SizedBox(height: 24),
                    _buildStatsRow(p),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    if (stepsLeft > 0) ...[
                      const SizedBox(height: 32),
                      _buildPromoBanner(stepsLeft),
                    ],
                    const SizedBox(height: 32),
                    _buildSectionTitle('Tổng quan', Icons.bar_chart_rounded, Colors.purple.shade400),
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
              child: Center(child: Image.network(avatarUrl, width: 70, height: 70, fit: BoxFit.contain)),
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
          statCol('🇯🇵', '+${p['coursesCount'] ?? 0}', 'Khóa học'),
          Container(width: 1.5, height: 40, color: borderColor),
          statCol('👥', '${p['followingCount'] ?? 0}', 'Đang theo dõi'),
          Container(width: 1.5, height: 40, color: borderColor),
          statCol('🌟', '${p['followersCount'] ?? 0}', 'Người theo dõi'),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.person_add_alt_1_rounded, color: textBlack, size: 18),
            label: Text('Thêm bạn', style: _txt(size: 15, weight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: borderColor, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            side: BorderSide(color: borderColor, width: 2),
            shape: const CircleBorder(),
            backgroundColor: Colors.white,
          ),
          child: Icon(Icons.ios_share_rounded, color: textBlack, size: 20),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(int steps) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🦉', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hoàn thiện hồ sơ', style: _txt(size: 17, weight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Còn $steps bước nữa thôi!', style: _txt(size: 13, isGrey: true)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orange.shade500, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Cập nhật ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Nunito')),
            ),
          ),
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
        card('🔥', '${p['streakDays'] ?? 0}', 'Chuỗi ngày'),
        card('⚡', '${p['totalXp'] ?? 0}', 'Tổng XP'),
        card('🛡️', p['currentLeague'] ?? 'Chưa có giải', 'Giải đấu'),
        card('🎯', p['learningGoal'] ?? 'Chưa đặt mục tiêu', 'Mục tiêu'),
      ],
    );
  }
}