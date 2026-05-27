class UserProfile {
  final String fullName;
  final String username;
  final String joinedDate;
  final String avatarUrl;
  final int coursesCount;
  final int followingCount;
  final int followersCount;
  final int stepsLeftToComplete;
  final int streakDays;
  final int totalXp;
  final String currentLeague;
  final String learningGoal;

  UserProfile({
    required this.fullName,
    required this.username,
    required this.joinedDate,
    required this.avatarUrl,
    required this.coursesCount,
    required this.followingCount,
    required this.followersCount,
    required this.stepsLeftToComplete,
    required this.streakDays,
    required this.totalXp,
    required this.currentLeague,
    required this.learningGoal,
  });

  // Hàm chuyển đổi JSON từ Backend Spring Boot sau này
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      joinedDate: json['joined_date'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      coursesCount: json['courses_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      stepsLeftToComplete: json['steps_left_to_complete'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      totalXp: json['total_xp'] ?? 0,
      currentLeague: json['current_league'] ?? '',
      learningGoal: json['learning_goal'] ?? '',
    );
  }
}