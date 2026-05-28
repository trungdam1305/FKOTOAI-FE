// Model cho thẻ Quiz vừa chơi gần nhất
class RecentQuiz {
  final String title;
  final int scorePercent;

  RecentQuiz({
    required this.title,
    required this.scorePercent,
  });

  factory RecentQuiz.fromJson(Map<String, dynamic> json) {
    return RecentQuiz(
      title: json['title'] ?? '',
      scorePercent: json['score_percent'] ?? 0,
    );
  }
}

// Model cho danh sách các phòng thi đấu trực tiếp
class LiveQuizRoom {
  final String iconEmoji;
  final int iconBgColorHex; // Trả về mã màu dạng Hex để UI tự render
  final String title;
  final String subtitle;
  final int totalQuizzes;

  LiveQuizRoom({
    required this.iconEmoji,
    required this.iconBgColorHex,
    required this.title,
    required this.subtitle,
    required this.totalQuizzes,
  });

  factory LiveQuizRoom.fromJson(Map<String, dynamic> json) {
    return LiveQuizRoom(
      iconEmoji: json['icon_emoji'] ?? '📝',
      iconBgColorHex: json['icon_bg_color_hex'] ?? 0xFFEEEEEE,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      totalQuizzes: json['total_quizzes'] ?? 0,
    );
  }
}

// Model tổng chứa toàn bộ dữ liệu của màn hình Quiz
class QuizScreenData {
  final RecentQuiz recentQuiz;
  final List<LiveQuizRoom> liveRooms;

  QuizScreenData({
    required this.recentQuiz,
    required this.liveRooms,
  });
}