import 'quiz_models.dart';

class QuizApiService {
  Future<QuizScreenData> fetchQuizData() async {
    // Giả lập thời gian kết nối mạng 800ms
    await Future.delayed(const Duration(milliseconds: 800));

    // Trả về dữ liệu cứng
    return QuizScreenData(
      recentQuiz: RecentQuiz(
        title: 'Luyện nghe N4 (Choukai)',
        scorePercent: 65,
      ),
      liveRooms: [
        LiveQuizRoom(
          iconEmoji: '📝',
          iconBgColorHex: 0xFFE8E9FC, // Xanh nhạt
          title: 'Ngữ pháp JLPT N4',
          subtitle: 'Từ vựng & Ngữ pháp',
          totalQuizzes: 12,
        ),
        LiveQuizRoom(
          iconEmoji: '💻',
          iconBgColorHex: 0xFFFDF0E3, // Cam nhạt
          title: 'IT Vocab (BrSE)',
          subtitle: 'Chuyên ngành IT',
          totalQuizzes: 8,
        ),
        LiveQuizRoom(
          iconEmoji: '🏯',
          iconBgColorHex: 0xFFE6F4EA, // Xanh lá nhạt
          title: 'Văn hóa Doanh nghiệp',
          subtitle: 'Kỹ năng mềm',
          totalQuizzes: 5,
        ),
      ],
    );
  }
}