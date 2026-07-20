import 'package:bim/features/quiz/domain/repositories/course_repository.dart';
import '../../data/repositories/course_repository_impl.dart';

class CourseController {
  final CourseRepository _repository = CourseRepositoryImpl();

  List<dynamic> courses = [];
  Map<String, dynamic>? selectedCourse;
  bool isLoading = false;

  void loadCourses({
    required String token,
    required Function() onLoading,
    required Function(List<dynamic> data) onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    isLoading = true;

    try {
      final data = await _repository.getCourses(token);

      courses = data;
      isLoading = false;

      onSuccess(data);
    } catch (e) {
      isLoading = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void loadCourseDetail({
    required String token,
    required String slug,
    required Function() onLoading,
    required Function(Map<String, dynamic> data) onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    isLoading = true;

    try {
      final data = await _repository.getCourseDetail(token, slug);

      selectedCourse = data;
      isLoading = false;

      onSuccess(data);
    } catch (e) {
      isLoading = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}