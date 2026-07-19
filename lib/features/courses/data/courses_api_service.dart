import 'courses_models.dart';

class CoursesApiService {
  Future<List<EnrolledCourse>> fetchMyCourses() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      EnrolledCourse(
        // Icon chú gà con 3D cực kỳ dễ thương cho cấp độ N5
        imageUrl: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Hatching%20Chick.png',
        title: 'Tiếng Nhật N5',
        subtitle: 'Chương 3: Khám phá Ngữ pháp',
        progressPercent: 0.65,
        totalLessons: 50,
        completedLessons: 36,
      ),
      EnrolledCourse(
        // Icon Núi Phú Sĩ 3D cho mục tiêu N4
        imageUrl: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Travel%20and%20places/Mount%20Fuji.png',
        title: 'Luyện thi JLPT N4',
        subtitle: 'Chương 1: Từ vựng Đời sống',
        progressPercent: 0.15,
        totalLessons: 80,
        completedLessons: 12,
      ),
    ];
  }
}