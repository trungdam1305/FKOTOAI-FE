import 'package:bim/features/quiz/domain/repositories/course_repository.dart';
import '../../data/repositories/course_repository_impl.dart';

class CourseController {
  final CourseRepository _repository = CourseRepositoryImpl();

  List<dynamic> courses = [];
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
}