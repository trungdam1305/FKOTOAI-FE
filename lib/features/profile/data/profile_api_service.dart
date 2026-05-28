import 'profile_models.dart';

class ProfileApiService {
  Future<UserProfile> fetchUserProfile() async {
    // Giả lập thời gian chờ mạng 800ms
    await Future.delayed(const Duration(milliseconds: 800));

    // Dữ liệu cứng (Hard Data) - Tuần 6 chỉ cần xóa đoạn này và gọi http.get
    return UserProfile(
      fullName: 'Đàm Quang Trung',
      username: '@trungdam',
      joinedDate: 'Tháng 6 2025',
      avatarUrl: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Technologist.png',
      coursesCount: 1,
      followingCount: 14,
      followersCount: 32,
      stepsLeftToComplete: 1,
      streakDays: 7,
      totalXp: 1525,
      currentLeague: 'Hạng Đồng',
      learningGoal: 'N4 BrSE',
    );
  }
}