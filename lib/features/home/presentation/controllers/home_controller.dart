import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';

class HomeController {
  final HomeRepository _repository = HomeRepositoryImpl();

  Map<String, dynamic>? studentProfile;
  Map<String, dynamic>? learningProgress;
  Map<String, dynamic>? continueChapter;
  List<dynamic> recentQuizzes = [];
  Map<String, dynamic>? aiChallenge;

  int rankPoints = 0;
  int streakCount = 0;
  int nationalRank = 0;
  double overallProgress = 0.0;
  String studentName = "Học viên";

  bool isLoading = false;

  void getDashboard({
    required String token,
    required Function() onLoading,
    required Function(Map<String, dynamic> data) onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    isLoading = true;
    try {
      final data = await _repository.getDashboardData(token);

      if (data != null) {
        studentProfile = data['studentProfile'];
        learningProgress = data['learningProgress'];
        continueChapter = data['continueChapter'];
        aiChallenge = data['aiChallenge'];

        recentQuizzes = data['recentQuizzes'] ?? [];
        nationalRank = data['nationalRank'] ?? 0;

        if (studentProfile != null) {
          studentName = studentProfile!['fullname'] ?? "Học viên";
          streakCount = studentProfile!['streakCount'] ?? 0;
          rankPoints = studentProfile!['rankPoints'] ?? 0;
        }

        if (learningProgress != null) {
          overallProgress = (learningProgress!['percentage'] ?? 0.0).toDouble();
        }
      }

      isLoading = false;

      onSuccess(data ?? {});
    } catch (e) {
      isLoading = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}