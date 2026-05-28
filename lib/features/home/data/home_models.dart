// Ánh xạ từ bảng `students` và tính toán từ `user_word_metrics`
class DashboardSummary {
  final int streakCount;
  final int rankPoints;
  final double progressPercent;
  final String recentActivityStr;

  DashboardSummary({
    required this.streakCount,
    required this.rankPoints,
    required this.progressPercent,
    required this.recentActivityStr,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      streakCount: json['streak_count'] ?? 0,
      rankPoints: json['rank_points'] ?? 1000,
      progressPercent: json['progress_percent']?.toDouble() ?? 0.0,
      recentActivityStr: json['recent_activity_str'] ?? '',
    );
  }
}

// Ánh xạ từ bảng `vocabulary` JOIN `user_word_metrics`
class WeakVocab {
  final int vocabId;
  final String word; // Kanji hoặc Hiragana
  final String reading;
  final String hanViet; // Âm Hán-Việt bắt buộc
  final String example;
  final String exampleMeaning;
  final int wrongCount; // Lấy từ cột total_wrong_count

  WeakVocab({
    required this.vocabId,
    required this.word,
    required this.reading,
    required this.hanViet,
    required this.example,
    required this.exampleMeaning,
    required this.wrongCount,
  });

  factory WeakVocab.fromJson(Map<String, dynamic> json) {
    return WeakVocab(
      vocabId: json['vocab_id'],
      word: json['word'],
      reading: json['reading'],
      hanViet: json['han_viet'] ?? '', // Xử lý null an toàn
      example: json['example_sentence'] ?? '',
      exampleMeaning: json['example_meaning'] ?? '',
      wrongCount: json['wrong_count'] ?? 0,
    );
  }
}