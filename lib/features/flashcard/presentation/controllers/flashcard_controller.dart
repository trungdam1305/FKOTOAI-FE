// Flashcard Controller (Riverpod Notifier)
import '../../data/repositories/flashcard_repository_impl.dart';
import '../../domain/repositories/flashcard_repository.dart';

class FlashcardController {
  final FlashcardRepository _repository = FlashcardRepositoryImpl();

  void fetchFlashcards({
    required String token,
    required Function() onLoading,
    required Function(Map<String, dynamic> data) onSuccess,
    required Function(String error) onError,
  }) async {
    onLoading();
    try {
      final data = await _repository.getFlashcards(token);
      onSuccess(data);
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}