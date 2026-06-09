import 'package:flutter/material.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/flashcard/data/repositories/progress_repository_impl.dart';

class ProgressScreen extends StatefulWidget {
  final String studentId;

  const ProgressScreen({super.key, required this.studentId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressRepositoryImpl _progressRepo = ProgressRepositoryImpl();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  bool _isLoading = true;
  String _errorMessage = '';
  String _realToken = '';


  Map<String, dynamic>? _progressData;
  List<dynamic> _weakVocabList = [];

  @override
  void initState() {
    super.initState();
    _initAuthAndFetchProgress();
  }

  Future<void> _initAuthAndFetchProgress() async {
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
      await _fetchProgressData();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi đọc mã xác thực hệ thống: $e';
      });
    }
  }

  Future<void> _fetchProgressData() async {
    try {
      final results = await Future.wait([
        _progressRepo.getMyProgress(_realToken, widget.studentId),
        _progressRepo.getMyWeakVocabulary(_realToken, widget.studentId, limit: 20),
      ]);

      if (!mounted) return;
      setState(() {
        _progressData = results[0] as Map<String, dynamic>?;
        _weakVocabList = results[1] as List<dynamic>? ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Tiến độ & Từ vựng yếu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
            onPressed: _initAuthAndFetchProgress,
          )
        ],
      ),
      body: _buildBody(),
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
            ElevatedButton(onPressed: _initAuthAndFetchProgress, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    double percentage = double.tryParse((_progressData?['progressPercentage'] ?? 0).toString()) ?? 0.0;
    if (percentage > 1.0) percentage /= 100.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng quan tiến độ học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đã thuộc: ${_progressData?['memorizedWords'] ?? 0} từ',
                              style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tổng số từ trong kho: ${_progressData?['totalWords'] ?? 0} từ',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(percentage * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 10,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Từ vựng cần ôn tập gấp (Top từ yếu nhất)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          _weakVocabList.isEmpty
              ? const Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Chúc mừng! Bạn không có từ vựng nào bị đánh giá là yếu.')),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _weakVocabList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _weakVocabList[index];

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
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.trending_down_rounded, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['word'] ?? item['front'] ?? 'N/A',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            if (item['furigana'] != null && item['furigana'].toString().isNotEmpty)
                              Text('Cách đọc: ${item['furigana']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text('Nghĩa: ${item['meaning'] ?? item['back'] ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      if (item['wrongCount'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            'Sai: ${item['wrongCount']} lần',
                            style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}