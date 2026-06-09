import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'VocabularyChapterScreen.dart';

class FlashcardDashboardScreen extends StatefulWidget {
  final VoidCallback? onExitPressed;
  final int chapterId;

  const FlashcardDashboardScreen({
    super.key,
    this.onExitPressed,
    required this.chapterId,
  });

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
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi đọc mã xác thực hệ thống: $e';
      });
    }
  }

  Future<void> _fetchFlashcardsData() async {
    try {
      final responseData = await _flashcardRepo.getFlashcards(_realToken, chapterId: widget.chapterId);

      if (!mounted) return;
      setState(() {
        _flashcards = responseData['result'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // [CREATE] Flashcard
  Future<void> _createFlashcard(String word, String furigana, String meaning) async {
    setState(() => _isLoading = true);
    try {
      // final response = await _flashcardRepo.createFlashcard(_realToken, chapterId: widget.chapterId, ...);

      await Future.delayed(const Duration(milliseconds: 500));

      final newCard = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'word': word,
        'furigana': furigana,
        'meaning': meaning,
        'status': 'NEW'
      };

      setState(() {
        _flashcards.insert(0, newCard);
        _isLoading = false;
      });
      _showSnackBar('Thêm thẻ từ vựng mới thành công!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi thêm thẻ: $e', isError: true);
    }
  }

  // [UPDATE] Flashcard
  Future<void> _updateFlashcard(dynamic cardId, String word, String furigana, String meaning) async {
    setState(() => _isLoading = true);
    try {
      // final response = await _flashcardRepo.updateFlashcard(_realToken, cardId: cardId, ...);

      await Future.delayed(const Duration(milliseconds: 500));


      setState(() {
        final index = _flashcards.indexWhere((element) => element['id'] == cardId);
        if (index != -1) {
          _flashcards[index]['word'] = word;
          _flashcards[index]['furigana'] = furigana;
          _flashcards[index]['meaning'] = meaning;
        }
        _isLoading = false;
      });
      _showSnackBar('Cập nhật thẻ từ vựng thành công!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi cập nhật thẻ: $e', isError: true);
    }
  }

  // [DELETE] Flashcard
  Future<void> _deleteFlashcard(dynamic cardId) async {
    setState(() => _isLoading = true);
    try {
      // await _flashcardRepo.deleteFlashcard(_realToken, cardId: cardId);

      await Future.delayed(const Duration(milliseconds: 400));

      setState(() {
        _flashcards.removeWhere((element) => element['id'] == cardId);
        _isLoading = false;
      });
      _showSnackBar('Đã xóa thẻ học khỏi chương này.');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi xóa thẻ: $e', isError: true);
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
                _updateFlashcard(selectedCard['id'], wordController.text.trim(), furiganaController.text.trim(), meaningController.text.trim());
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

  // DELETE Flashcard
  void _confirmDeleteFlashcard(dynamic cardId) {
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
              _deleteFlashcard(cardId);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Thư viện Flashcard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: widget.onExitPressed != null
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: widget.onExitPressed)
            : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
            onPressed: _initAuthAndFetchFlashcards,
          )
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _openFlashcardFormDialog(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _initAuthAndFetchFlashcards, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danh sách thẻ học chương này', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _flashcards.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VocabularyChapterScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text('Bắt đầu học lật thẻ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _flashcards.isEmpty
                ? const Center(child: Text('Không có thẻ học nào trong chương này.'))
                : ListView.separated(
              itemCount: _flashcards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final card = _flashcards[index];

                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.style_rounded, color: Colors.purple, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(card['word'] ?? card['front'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              if (card['furigana'] != null && card['furigana'].toString().isNotEmpty)
                                Text('Cách đọc: ${card['furigana']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('Nghĩa: ${card['meaning'] ?? card['back'] ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (card['status'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: card['status'] == "MEMORIZED" ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  card['status'] == "MEMORIZED" ? "Đã thuộc" : "Chưa thuộc",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: card['status'] == "MEMORIZED" ? Colors.green : Colors.amber[800]
                                  ),
                                ),
                              ),

                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openFlashcardFormDialog(selectedCard: card);
                                } else if (value == 'delete') {
                                  _confirmDeleteFlashcard(card['id']);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                                      SizedBox(width: 8),
                                      Text('Sửa thẻ'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_forever_rounded, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Xóa thẻ'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}