class EnrolledCourse {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double progressPercent;
  final int totalLessons;
  final int completedLessons;

  EnrolledCourse({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.progressPercent,
    required this.totalLessons,
    required this.completedLessons,
  });

  // Hàm chuyển đổi JSON từ Backend sau này
  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    return EnrolledCourse(
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      progressPercent: json['progress_percent']?.toDouble() ?? 0.0,
      totalLessons: json['total_lessons'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
    );
  }
}