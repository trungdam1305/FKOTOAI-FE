import 'package:flutter/material.dart';
import 'package:bim/features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'flashcard_learning_screen.dart';

class FlashcardDashboardScreen extends StatefulWidget {
  final VoidCallback? onExitPressed;
  const FlashcardDashboardScreen({super.key, this.onExitPressed});

  @override
  State<FlashcardDashboardScreen> createState() => _FlashcardDashboardScreenState();
}

class _FlashcardDashboardScreenState extends State<FlashcardDashboardScreen> {
  final FlashcardRepositoryImpl _flashcardRepo = FlashcardRepositoryImpl();

  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _folders = [];

  final String _token = "dummy_user_token";

  @override
  void initState() {
    super.initState();
    _fetchFoldersData();
  }

  // 📥 Tải dữ liệu bộ học phần từ API Server
  Future<void> _fetchFoldersData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final data = await _flashcardRepo.fetchCollections(_token);
      setState(() { _folders = data; _isLoading = false; });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _createFolder(String title, String desc) async {
    try {
      await _flashcardRepo.createCollection(_token, title, desc);
      await _fetchFoldersData();
      _showSnackBar('Đã tạo học phần mới thành công!');
    } catch (e) { _showSnackBar('Lỗi: $e'); }
  }

  // ✏️ Sửa tên Folder
  Future<void> _updateFolder(int index, String title, String desc) async {
    final folderId = _folders[index]['id'].toString();
    try {
      await _flashcardRepo.updateCollection(_token, folderId, title, desc);
      await _fetchFoldersData();
      _showSnackBar('Đã cập nhật học phần!');
    } catch (e) { _showSnackBar('Lỗi: $e'); }
  }

  // 🗑️ Xóa sạch Folder khỏi hệ thống
  Future<void> _deleteFolder(int index) async {
    final folderId = _folders[index]['id'].toString();
    try {
      await _flashcardRepo.deleteCollection(_token, folderId);
      await _fetchFoldersData();
      _showSnackBar('Đã xóa học phần.');
    } catch (e) { _showSnackBar('Lỗi: $e'); }
  }

  // ➕ Thêm thẻ từ nhỏ vào Folder cụ thể
  Future<void> _addCardToFolder(int folderIndex, Map<String, String> cardData) async {
    final folderId = _folders[folderIndex]['id'].toString();
    try {
      await _flashcardRepo.addCard(_token, folderId, cardData);
      await _fetchFoldersData();
      _showSnackBar('Đã thêm từ mới vào học phần!');
    } catch (e) { _showSnackBar('Lỗi: $e'); }
  }

  // ✏️ Sửa thông tin một thẻ từ nhỏ
  Future<void> _updateCardInFolder(int folderIndex, int cardIndex, Map<String, String> cardData) async {
    final folderId = _folders[folderIndex]['id'].toString();
    final cardId = (_folders[folderIndex]['flashcards'][cardIndex]['id'] ?? cardIndex).toString();
    try {
      await _flashcardRepo.updateCard(_token, folderId, cardId, cardData);
      await _fetchFoldersData();
      _showSnackBar('Đã sửa từ vựng!');
    } catch (e) { _showSnackBar('Lỗi: $e'); }
  }

  // 🗑️ Xóa một thẻ từ nhỏ ra khỏi tập hồ sơ
  Future<void> _deleteCardFromFolder(int folderIndex, int cardIndex) async {
    final folderId = _folders[folderIndex]['id'].toString();
    final cardId = (_folders[folderIndex]['flashcards'][cardIndex]['id'] ?? cardIndex).toString();
    try {
      await _flashcardRepo.deleteCard(_token, folderId, cardId);
      await _fetchFoldersData();
      _showSnackBar('Đã xóa từ vựng khỏi học phần.');
    } catch (e) { _showSnackBar('Lỗi: $e'); }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  // =========================================================================
  // DIALOG THÊM / SỬA THƯ MỤC LỚN
  // =========================================================================
  void _showFolderDialog({int? index}) {
    final isEdit = index != null;
    final titleCtrl = TextEditingController(text: isEdit ? _folders[index]['title'] : '');
    final descCtrl = TextEditingController(text: isEdit ? _folders[index]['description'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa tên học phần' : 'Tạo học phần mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên học phần (Ví dụ: Bài 3)')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả ngắn')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              if (isEdit) {
                _updateFolder(index, titleCtrl.text.trim(), descCtrl.text.trim());
              } else {
                _createFolder(titleCtrl.text.trim(), descCtrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Cập nhật' : 'Tạo'),
          )
        ],
      ),
    );
  }

  // =========================================================================
  // DIALOG THÊM / SỬA THẺ TỪ NHỎ (DÙNG CHO MÀN CHI TIẾT)
  // =========================================================================
  void _showCardDialog(BuildContext context, int folderIndex, {int? cardIndex}) {
    final isEdit = cardIndex != null;
    final folder = _folders[folderIndex];
    final card = isEdit ? folder['flashcards'][cardIndex] : null;

    final wordCtrl = TextEditingController(text: isEdit ? card['word'] : '');
    final furiganaCtrl = TextEditingController(text: isEdit ? card['furigana'] : '');
    final meaningCtrl = TextEditingController(text: isEdit ? card['meaning'] : '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Sửa thẻ từ' : 'Thêm từ mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: wordCtrl, decoration: const InputDecoration(labelText: 'Từ vựng (Kanji)')),
            TextField(controller: furiganaCtrl, decoration: const InputDecoration(labelText: 'Furigana')),
            TextField(controller: meaningCtrl, decoration: const InputDecoration(labelText: 'Nghĩa tiếng Việt')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (wordCtrl.text.trim().isEmpty || meaningCtrl.text.trim().isEmpty) return;
              final data = {
                "word": wordCtrl.text.trim(),
                "furigana": furiganaCtrl.text.trim(),
                "meaning": meaningCtrl.text.trim(),
                "type": "Từ vựng",
                "example_jp": "",
                "example_vi": ""
              };
              if (isEdit) {
                _updateCardInFolder(folderIndex, cardIndex, data);
              } else {
                _addCardToFolder(folderIndex, data);
              }
              Navigator.pop(dialogContext);
            },
            child: Text(isEdit ? 'Lưu' : 'Thêm'),
          )
        ],
      ),
    );
  }

  // =========================================================================
  // MÀN HÌNH CHI TIẾT BÊN TRONG CỦA MỘT THƯ MỤC (XEM & CRUD THẺ NHỎ)
  // =========================================================================
  void _openFolderDetail(int folderIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setDetailState) {
            final folder = _folders[folderIndex];
            final List cards = folder['flashcards'] ?? [];

            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                title: Text(folder['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: cards.isEmpty
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardLearningScreen(flashcards: cards),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        label: const Text('Bắt đầu học lật thẻ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Các từ vựng trong học phần (${cards.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: cards.isEmpty
                          ? const Center(child: Text('Học phần này chưa có từ nào. Ấn (+) để thêm.'))
                          : ListView.separated(
                        itemCount: cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, cardIndex) {
                          final card = cards[cardIndex];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(card['word'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                              subtitle: Text('${card['furigana'] ?? ''} \n${card['meaning'] ?? ''}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.amber),
                                    onPressed: () {
                                      _showCardDialog(context, folderIndex, cardIndex: cardIndex);
                                      setDetailState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () {
                                      _deleteCardFromFolder(folderIndex, cardIndex);
                                      setDetailState(() {});
                                    },
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
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.purple,
                onPressed: () {
                  _showCardDialog(context, folderIndex);
                  setDetailState(() {});
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        ),
      ),
    ).then((_) => _fetchFoldersData());
  }

  // =========================================================================
  // GIAO DIỆN CHÍNH DASHBOARD
  // =========================================================================
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
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
            onPressed: _fetchFoldersData,
          )
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isLoading || _errorMessage.isNotEmpty
          ? null
          : FloatingActionButton(
        onPressed: () => _showFolderDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.create_new_folder_rounded, color: Colors.white),
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
            ElevatedButton(onPressed: _fetchFoldersData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Học phần của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: _folders.isEmpty
                ? const Center(child: Text('Chưa có học phần nào. Nhấn (+) để tạo mới nhé!'))
                : ListView.separated(
              itemCount: _folders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final folder = _folders[index];
                final List cards = folder['flashcards'] ?? [];

                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    onTap: () => _openFolderDetail(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.folder_special_rounded, color: Colors.purple, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(folder['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(folder['description'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 6),
                                Text('${cards.length} thuật ngữ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue)),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.edit_note, color: Colors.grey), onPressed: () => _showFolderDialog(index: index)),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteFolder(index)),
                        ],
                      ),
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