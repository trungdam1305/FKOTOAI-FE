import 'package:flutter/material.dart';
import '../data/profile_models.dart';
import '../data/profile_api_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final Color primaryBlue = const Color(0xFF3B40E8);
  final Color textBlack = const Color(0xFF2D2D2D);
  final Color textGrey = const Color(0xFF757575);
  final Color borderColor = Colors.grey.shade200;
  final Color bgCard = const Color(0xFFF8F9FA);

  final ProfileApiService _apiService = ProfileApiService();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _apiService.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải dữ liệu', style: TextStyle(fontFamily: 'Nunito', color: textBlack)));
        }

        final UserProfile profile = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(profile.avatarUrl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildProfileInfo(profile),
                    const SizedBox(height: 24),
                    _buildStatsRow(profile),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 32),

                    if (profile.stepsLeftToComplete > 0) ...[
                      _buildPromoBanner(profile.stepsLeftToComplete),
                      const SizedBox(height: 32),
                    ],

                    _buildSectionTitle('Tổng quan', Icons.bar_chart_rounded, Colors.purple.shade400),
                    const SizedBox(height: 16),
                    _buildOverviewGrid(profile),
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

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito', letterSpacing: 0.3),
        ),
      ],
    );
  }

  Widget _buildHeader(String avatarUrl) {
    return Container(
      width: double.infinity,
      height: 180,
      color: bgCard, // Dùng nền giấy thay vì xanh nhạt
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
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
              ),
              child: Center(child: Image.network(avatarUrl, width: 70, height: 70, fit: BoxFit.contain)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa profile cho hài hòa
      children: [
        Center(
          child: Text(
            profile.fullName,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textBlack, fontFamily: 'Nunito'),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            '${profile.username} • Tham gia ${profile.joinedDate}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textGrey, fontFamily: 'Nunito'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('🇯🇵', '+${profile.coursesCount}', 'Khóa học'),
          Container(width: 1.5, height: 40, color: borderColor),
          _buildStatColumn('👥', '${profile.followingCount}', 'Đang theo dõi'),
          Container(width: 1.5, height: 40, color: borderColor),
          _buildStatColumn('🌟', '${profile.followersCount}', 'Người theo dõi'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String emoji, String count, String label) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito')),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.person_add_alt_1_rounded, color: textBlack, size: 18),
            label: Text(
              'Thêm bạn',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito'),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: borderColor, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Pill shape
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
            shape: const CircleBorder(), // Nút share hình tròn mộc mạc
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
                    Text(
                      'Hoàn thiện hồ sơ',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Còn $steps bước nữa thôi!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textGrey, fontFamily: 'Nunito'),
                    ),
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
                backgroundColor: Colors.orange.shade500,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text(
                'Cập nhật ngay',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Nunito'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(UserProfile profile) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(icon: '🔥', title: '${profile.streakDays}', subtitle: 'Chuỗi ngày'),
        _buildStatCard(icon: '⚡', title: '${profile.totalXp}', subtitle: 'Tổng XP'),
        _buildStatCard(icon: '🛡️', title: profile.currentLeague, subtitle: 'Giải đấu'),
        _buildStatCard(icon: '🎯', title: profile.learningGoal, subtitle: 'Mục tiêu'),
      ],
    );
  }

  Widget _buildStatCard({required String icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito'),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textGrey, fontFamily: 'Nunito'),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}