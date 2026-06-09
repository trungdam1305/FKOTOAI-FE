import 'package:flutter/material.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/flashcard/data/repositories/VocabularyChapterRepositoryImpl.dart';
import 'flashcard_dashboard_screen.dart';

class VocabularyChapterScreen extends StatefulWidget {
  final VoidCallback? onExitPressed;
  const VocabularyChapterScreen({super.key, this.onExitPressed});

  @override
  State<VocabularyChapterScreen> createState() => _VocabularyChapterScreenState();
}

class _VocabularyChapterScreenState extends State<VocabularyChapterScreen> {
  final VocabularyChapterRepositoryImpl _chapterRepo = VocabularyChapterRepositoryImpl();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _chapters = [];

  String _realToken = '';
  final String _studentId = "";

  @override
  void initState() {
    super.initState();
    _initAuthAndFetchChapters();
  }

  Future<void> _initAuthAndFetchChapters() async {
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
      await _fetchChapters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi đọc mã xác thực hệ thống: $e';
      });
    }
  }

  Future<void> _fetchChapters() async {
    try {
      final data = await _chapterRepo.getMyChapters(_realToken, _studentId);
      if (!mounted) return;
      setState(() {
        _chapters = data;
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

  Future<void> _createNewChapter(String title, String desc) async {
    try {
      final int nextOrderIndex = _chapters.length + 1;
      const String defaultLevel = "N5";

      await _chapterRepo.createChapter(
        _realToken,
        _studentId,
        title,
        desc,
        defaultLevel,
        nextOrderIndex,
      );
      await _fetchChapters();
      _showSnackBar('Đã tạo chương học mới thành công!');
    } catch (e) {
      _showSnackBar('Lỗi tạo chương: $e', isError: true);
    }
  }

  Future<void> _editChapter(int id, String title, String desc, String level, int orderIndex) async {
    try {
      await _chapterRepo.updateChapter(
        _realToken,
        id,
        _studentId,
        title,
        desc,
        level,
        orderIndex,
      );
      await _fetchChapters();
      _showSnackBar('Đã cập nhật thông tin chương!');
    } catch (e) {
      _showSnackBar('Lỗi sửa: $e', isError: true);
    }
  }

  void _confirmDeleteChapter(dynamic chapter) {
    if (chapter == null) return;

    final dynamic rawId = chapter['id'] ?? chapter['chapterId'] ?? chapter['vocabularyChapterId'];
    if (rawId == null) {
      _showSnackBar('Lỗi: Không tìm thấy trường ID hợp lệ trong dữ liệu chương học này!', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text('Bạn có chắc chắn muốn xóa không?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _executeDeleteChapter(int.parse(rawId.toString()));
                  },
                  child: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. DELETE
  Future<void> _executeDeleteChapter(int parsedChapterId) async {
    setState(() => _isLoading = true);
    try {
      await _chapterRepo.deleteChapter(_realToken, parsedChapterId, _studentId);
      await _fetchChapters();
      _showSnackBar('Đã xóa chương học thành công.');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi xóa chương: $e', isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showChapterDialog({dynamic chapter}) {
    final isEdit = chapter != null;

    final titleCtrl = TextEditingController(text: isEdit ? (chapter['chapterName'] ?? '') : '');
    final descCtrl = TextEditingController(text: isEdit ? (chapter['description'] ?? '') : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Sửa chương học' : 'Tạo chương học mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tên chương học'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả ngắn'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) {
                _showSnackBar('Vui lòng điền tên chương học!', isError: true);
                return;
              }
              if (isEdit) {
                final dynamic rawId = chapter['id'] ?? chapter['chapterId'] ?? chapter['vocabularyChapterId'];
                if (rawId != null) {
                  _editChapter(
                    int.parse(rawId.toString()),
                    titleCtrl.text.trim(),
                    descCtrl.text.trim(),
                    chapter['level'] ?? "N5",
                    chapter['orderIndex'] ?? 1,
                  );
                } else {
                  _showSnackBar('Không thể cập nhật do không tìm thấy ID!', isError: true);
                }
              } else {
                _createNewChapter(titleCtrl.text.trim(), descCtrl.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(isEdit ? 'Cập nhật' : 'Tạo', style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Từ vựng & Học phần', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: widget.onExitPressed != null
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20), onPressed: widget.onExitPressed)
            : IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.blue), onPressed: _initAuthAndFetchChapters)
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isLoading || _errorMessage.isNotEmpty
          ? null
          : FloatingActionButton(
        onPressed: () => _showChapterDialog(),
        backgroundColor: Colors.blue,
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
              child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _initAuthAndFetchChapters, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    final int totalChapters = _chapters.length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng quan kho từ vựng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Số lượng chương học cá nhân', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('$totalChapters Chương', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalChapters > 0 ? 1.0 : 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Danh sách chương học của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _chapters.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Bạn chưa tạo chương từ vựng nào.\nNhấn nút (+) ở góc dưới để tạo mới ngay!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
            ),
          )
              : Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _chapters.length,
              separatorBuilder: (_, __) => const Divider(height: 16, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final chapter = _chapters[index];

                return InkWell(
                  onTap: () {
                    final dynamic rawId = chapter['id'] ?? chapter['chapterId'] ?? chapter['vocabularyChapterId'];
                    if (rawId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardDashboardScreen(
                            chapterId: int.parse(rawId.toString()),
                          ),
                        ),
                      );
                    } else {
                      _showSnackBar('Không tìm thấy ID hợp lệ cho chương học này!', isError: true);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.style_rounded, color: Colors.purple, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter['chapterName'] ?? 'Không tên',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chapter['description'] ?? 'Chưa có mô tả chi tiết',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.amber, size: 24),
                          onPressed: () => _showChapterDialog(chapter: chapter),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                          onPressed: () => _confirmDeleteChapter(chapter),
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