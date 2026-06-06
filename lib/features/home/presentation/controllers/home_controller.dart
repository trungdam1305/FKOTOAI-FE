import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';

class HomeController {
  final HomeRepository _repository = HomeRepositoryImpl();

  List<dynamic> homeFlashcards = [];
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

      if (data != null && data['flashcards'] != null) {
        homeFlashcards = data['flashcards'];
      } else {
        homeFlashcards = [];
      }

      isLoading = false;
      onSuccess(data);
    } catch (e) {
      isLoading = false;
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}