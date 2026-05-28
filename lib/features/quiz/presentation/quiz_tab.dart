import 'package:flutter/material.dart';
import '../data/quiz_models.dart';
import '../data/quiz_api_service.dart';

class QuizTab extends StatefulWidget {
  const QuizTab({Key? key}) : super(key: key);

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  final Color primaryBlue = const Color(0xFF3B40E8);
  final Color textBlack = const Color(0xFF2D2D2D);
  final Color textGrey = const Color(0xFF757575);
  final Color borderColor = Colors.grey.shade200;
  final Color bgCard = const Color(0xFFF8F9FA);

  final QuizApiService _apiService = QuizApiService();
  late Future<QuizScreenData> _quizDataFuture;

  @override
  void initState() {
    super.initState();
    _quizDataFuture = _apiService.fetchQuizData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<QuizScreenData>(
          future: _quizDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryBlue));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi tải dữ liệu thi đấu!', style: TextStyle(fontFamily: 'Nunito', color: textBlack)));
            }

            final QuizScreenData data = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  _buildRecentQuizCard(data.recentQuiz),
                  const SizedBox(height: 20),
                  _buildFeaturedCard(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Phòng Thi Đấu', Icons.emoji_events_outlined, Colors.teal),
                  const SizedBox(height: 16),

                  ...data.liveRooms.map((room) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildLiveQuizItem(room),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
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
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito', letterSpacing: 0.3),
          ),
        ),
        Text(
          'Xem tất cả',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryBlue, fontFamily: 'Nunito'),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Text(
                  'CHÀO BUỔI SÁNG',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textGrey, letterSpacing: 1.0, fontFamily: 'Nunito'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Đàm Quang Trung',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: bgCard, shape: BoxShape.circle, border: Border.all(color: borderColor, width: 2)),
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage('https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Technologist.png'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentQuizCard(RecentQuiz recentQuiz) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5), // Nền hồng giấy
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE3E3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUIZ VỪA CHƠI',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.red.shade700, letterSpacing: 1.2, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.history_rounded, color: Colors.red.shade800, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recentQuiz.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito'),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.red.shade100, width: 2)),
            child: Center(
              child: Text(
                '${recentQuiz.scorePercent}%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.red.shade700, fontFamily: 'Nunito'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryBlue.withOpacity(0.15), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'THỬ THÁCH',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: primaryBlue, letterSpacing: 1.5, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 12),
          Text(
            'Tham gia thi đấu cùng\nbạn bè hoặc người chơi khác',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textBlack, height: 1.4, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.people_alt_outlined, color: Colors.white, size: 18),
            label: const Text(
              'Tìm Đối Thủ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Nunito'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), // Pill shape
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveQuizItem(LiveQuizRoom room) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Color(room.iconBgColorHex),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(room.iconEmoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito')),
                const SizedBox(height: 4),
                Text('${room.subtitle} • ${room.totalQuizzes} Quizzes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textGrey, fontFamily: 'Nunito')),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
        ],
      ),
    );
  }
}