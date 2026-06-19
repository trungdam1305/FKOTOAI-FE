import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'VocabularyChapterScreen.dart';
import 'VocabularyScreen.dart';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/gradient_background.dart';

class FlashcardDashboardScreen extends StatefulWidget {
  final VoidCallback? onExitPressed;
  final int chapterId;

  const FlashcardDashboardScreen({super.key, this.onExitPressed, required this.chapterId,});

  @override
  State<FlashcardDashboardScreen> createState() => _FlashcardDashboardScreenState();
}

class _FlashcardDashboardScreenState extends State<FlashcardDashboardScreen> {
  final FlashcardRepositoryImpl _flashcardRepo = FlashcardRepositoryImpl();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _flashcards = [];
  String _realToken = '';

  @override
  void initState() {
    super.initState();
    _initAuthAndFetchFlashcards();
  }

  Future<void> _initAuthAndFetchFlashcards() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String? userToken = await _authLocalDataSource.getToken();

      if (userToken == null || userToken.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại!';
        });
        return;
      }

      _realToken = userToken;
      await _fetchFlashcardsData();
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _fetchFlashcardsData() async {
    try {
      final List<dynamic> data = await _flashcardRepo.getVocabsInChapter(_realToken, widget.chapterId);
      if (mounted) setState(() { _flashcards = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  // [CREATE] Flashcard
  Future<void> _createFlashcard(String word, String furigana, String meaning) async {
    setState(() => _isLoading = true);
    try {
      final response = await _flashcardRepo.addVocabToChapter(_realToken, widget.chapterId, word, meaning);
      await _fetchFlashcardsData();
      _showSnackBar('Thêm thẻ từ vựng mới thành công!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi thêm thẻ: $e', isError: true);
    }
  }

  // [UPDATE] Flashcard
  Future<void> _updateFlashcard(dynamic vocabId, String word, String furigana, String meaning) async {
    setState(() => _isLoading = true);
    try {
      await _flashcardRepo.updateVocabInChapter(_realToken, widget.chapterId, vocabId, word, meaning);

      await _fetchFlashcardsData();

      _showSnackBar('Cập nhật thẻ thành công!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi cập nhật: $e', isError: true);
    }
  }

  // [DELETE] Flashcard
  Future<void> _deleteFlashcard(dynamic vocabId) async {
    try {
      await _flashcardRepo.removeVocabFromChapter(_realToken, widget.chapterId, vocabId);

      await _fetchFlashcardsData();

      if (mounted) _showSnackBar('Đã xóa thẻ học.');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Lỗi xóa thẻ: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
      }
    }
  }

  void _openFlashcardFormDialog({Map<String, dynamic>? selectedCard}) {
    final isEditMode = selectedCard != null;
    final wordController = TextEditingController(text: isEditMode ? (selectedCard['word'] ?? selectedCard['front'] ?? '') : '');
    final furiganaController = TextEditingController(text: isEditMode ? (selectedCard['furigana'] ?? '') : '');
    final meaningController = TextEditingController(text: isEditMode ? (selectedCard['meaning'] ?? selectedCard['back'] ?? '') : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditMode ? 'Chỉnh sửa từ vựng' : 'Thêm từ vựng mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordController,
                decoration: const InputDecoration(labelText: 'Từ vựng / Kanji *', hintText: 'Ví dụ: 日本語'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: furiganaController,
                decoration: const InputDecoration(labelText: 'Cách đọc / Furigana', hintText: 'Ví dụ: にほんご'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: meaningController,
                decoration: const InputDecoration(labelText: 'Nghĩa tiếng Việt *', hintText: 'Ví dụ: Tiếng Nhật'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              if (wordController.text.trim().isEmpty || meaningController.text.trim().isEmpty) {
                _showSnackBar('Vui lòng nhập đầy đủ các trường bắt buộc (*)', isError: true);
                return;
              }
              Navigator.pop(context);
              if (isEditMode) {
                _updateFlashcard(selectedCard['itemId'], wordController.text.trim(), furiganaController.text.trim(), meaningController.text.trim());
              } else {
                _createFlashcard(wordController.text.trim(), furiganaController.text.trim(), meaningController.text.trim());
              }
            },
            child: Text(isEditMode ? 'Cập nhật' : 'Thêm mới', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // cf DELETE Flashcard
  void _confirmDeleteFlashcard(dynamic cardId) {
    final int? id = (cardId is int) ? cardId : int.tryParse(cardId.toString());

    if (id == null) {
      _showSnackBar('Lỗi: ID thẻ không hợp lệ', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa thẻ từ vựng này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFlashcard(id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.midnightBlue,
          title: const Text('Thư viện Flashcard', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: widget.onExitPressed ?? () => Navigator.pop(context)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initAuthAndFetchFlashcards)],
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildList(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _openFlashcardFormDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _flashcards.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => VocabularyScreen(flashcards: _flashcards))),
          child: const Text('Bắt đầu học', style: TextStyle(color: Colors.white)),
        )),
        const SizedBox(height: 16),
        Expanded(child: ListView.builder(
            itemCount: _flashcards.length,
            itemBuilder: (_, i) {
              final card = _flashcards[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.style, color: AppColors.primary),
                  title: Text(card['word'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(card['meaning'] ?? ''),
                  trailing: PopupMenuButton(
                    onSelected: (v) => v == 'edit' ? _openFlashcardFormDialog(selectedCard: card) : _confirmDeleteFlashcard(card['itemId']),
                    itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text('Sửa')), const PopupMenuItem(value: 'delete', child: Text('Xóa'))],
                  ),
                ),
              );
            }
        ))
      ]),
    );
  }
}