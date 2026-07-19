import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/flashcard/presentation/screens/VocabularyChapterScreen.dart';
import 'package:bim/features/flashcard/presentation/screens/progress_screen.dart';
import 'package:bim/features/tools/presentation/screens/ocr_screen.dart';


class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final HomeController _homeController = HomeController();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  Map<String, dynamic>? _dashboardData;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  void _fetchHomeData() async {
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

      _homeController.getDashboard(
        token: userToken,
        onLoading: () {},
        onSuccess: (data) => setState(() { _isLoading = false; _dashboardData = data; }),
        onError: (error) => setState(() { _isLoading = false; _errorMessage = error; }),
      );
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = 'Lỗi hệ thống: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchHomeData,
              child: const Text('Thử tải lại'),
            ),
          ],
        ),
      );
    }

    if (_dashboardData == null) return const Center(child: Text('Không có dữ liệu hiển thị.'));

    final String name = _homeController.studentName;
    final double progress = _homeController.overallProgress;
    final String level = _dashboardData!['continueChapter'] != null ? 'N5' : 'N4';
    final List recentQuizzes = _dashboardData!['recentQuizzes'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(name, level),
          const SizedBox(height: 24),

          InkWell(
            onTap: _navigateToProgressScreen,
            borderRadius: BorderRadius.circular(16),
            child: _buildProgressCard(progress, level),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Tính năng hệ thống'),
          const SizedBox(height: 12),
          _buildFeatureGrid(),
          const SizedBox(height: 24),

          _buildSectionTitle('Bài kiểm tra gần đây (Quiz)'),
          const SizedBox(height: 12),
          recentQuizzes.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Bạn chưa thực hiện bài Quiz nào gần đây.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
              : Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentQuizzes.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = recentQuizzes[index];
                return Row(
                  children: [
                    const Icon(Icons.quiz_outlined, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loại kiểm tra: ${item['attemptType'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kết quả: ${item['passFail'] ?? 'N/A'} - Đúng ${item['correctCount'] ?? 0}/${item['totalQuestions'] ?? 0}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Điểm: ${item['score'] ?? '0'}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHeader(String name, String level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chào mừng quay trở lại, 👋', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            level,
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress, String level) {
    return Container(
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
          const Text('Tiến độ học tập hiện tại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mục tiêu khóa $level', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text(
                '${(progress > 1.0 ? progress : progress * 100).toInt()}% Hoàn thành',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? progress / 100 : progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildFeatureItem(Icons.style_rounded, 'Flashcards', Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VocabularyChapterScreen(),
            ),
          );
        }),
        _buildFeatureItem(Icons.quiz_rounded, 'Online Quiz', Colors.orange, () {
        }),
        _buildFeatureItem(Icons.analytics_rounded, 'Dashboard', Colors.teal, () {
          _navigateToProgressScreen();
        }),
        _buildFeatureItem(Icons.camera_alt_rounded, 'Tra từ OCR', const Color(0xFF3B40E8), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OcrScreen(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProgressScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressScreen(
          studentId: _dashboardData?['studentId']?.toString() ?? '',
        ),
      ),
    );
  }
}