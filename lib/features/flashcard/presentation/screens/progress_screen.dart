import 'package:flutter/material.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/flashcard/data/repositories/progress_repository_impl.dart';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/gradient_background.dart';

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
    if (!mounted) return; setState(() {_isLoading = true;_errorMessage = '';});

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
    double percentage = double.tryParse((_progressData?['progressPercentage'] ?? 0).toString()) ?? 0.0;
    if (percentage > 1.0) percentage /= 100.0;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.midnightBlue,
          title: const Text('Tiến độ & Từ vựng yếu', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initAuthAndFetchProgress)],
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(percentage),
      ),
    );
  }

  Widget _buildBody(double percentage) {
    if (_errorMessage.isNotEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_errorMessage, style: const TextStyle(color: Colors.red)), ElevatedButton(onPressed: _initAuthAndFetchProgress, child: const Text('Thử lại'))]));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tổng quan tiến độ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Đã thuộc: ${_progressData?['memorizedWords'] ?? 0}'),
                  Text('Tổng: ${_progressData?['totalWords'] ?? 0}', style: const TextStyle(color: Colors.grey)),
                ]),
                Text('${(percentage * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ]),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: percentage, color: AppColors.primary, backgroundColor: AppColors.primary.withOpacity(0.1)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Từ vựng cần ôn tập gấp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._weakVocabList.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.trending_down, color: Colors.red),
            title: Text(item['word'] ?? item['front'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Nghĩa: ${item['meaning'] ?? item['back'] ?? ''}'),
            trailing: Text('Sai: ${item['wrongCount'] ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        )),
      ]),
    );
  }
}