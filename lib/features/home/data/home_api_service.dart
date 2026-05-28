import 'home_models.dart';

class HomeApiService {
  // Hàm này giả lập việc gọi API: GET /api/v1/student/home-home
  Future<Map<String, dynamic>> fetchHomeData() async {
    // Giả lập độ trễ mạng 1.5 giây
    await Future.delayed(const Duration(milliseconds: 1500));

    // Đây chính là cấu trúc JSON mà Spring Boot CẦN trả về sau này
    return {
      "dashboard_summary": {
        "streak_count": 7,
        "rank_points": 1120,
        "progress_percent": 0.65, // 65%
        "recent_activity_str": "Vượt qua Mini Quiz N5 (66.67đ)"
      },
      "weak_vocabularies": [
        {
          "vocab_id": 2,
          "word": "学生",
          "reading": "がくせい",
          "han_viet": "HỌC SINH",
          "example_sentence": "私は学生です。",
          "example_meaning": "Tôi là học sinh.",
          "wrong_count": 5
        },
        {
          "vocab_id": 6,
          "word": "勉強",
          "reading": "べんきょう",
          "han_viet": "MIỄN CƯỜNG",
          "example_sentence": "日本語を勉強します。",
          "example_meaning": "Tôi học tiếng Nhật.",
          "wrong_count": 3
        }
      ]
    };
  }
}