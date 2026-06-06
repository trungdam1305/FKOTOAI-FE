import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import 'package:bim/features/flashcard/presentation/screens/flashcard_learning_screen.dart';
import 'package:bim/features/flashcard/presentation/screens/flashcard_dashboard_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {

  final HomeController _homeController = HomeController();
  Map<String, dynamic>? _dashboardData;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  void _fetchHomeData() {
    String userToken = "dummy_user_token";
    _homeController.getDashboard(
      token: userToken,
      onLoading: () => setState(() { _isLoading = true; _errorMessage = ''; }),
      onSuccess: (data) {
        setState(() {
          _isLoading = false;
          _dashboardData = data;

          _homeController.homeFlashcards = data['flashcards'] ?? [];
        });
      },
      onError: (error) => setState(() { _isLoading = false; _errorMessage = error; }),
    );
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
            Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchHomeData, child: const Text('Thử tải lại')),
          ],
        ),
      );
    }

    if (_dashboardData == null) return const Center(child: Text('Không có dữ liệu hiển thị.'));

    final data = _dashboardData!;
    final List recommendedLessons = data['recommendedLessons'] ?? [];
    final List recentActivities = data['recentActivities'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header chào hỏi
          _buildHeader(data['studentName'] ?? 'Học viên', data['currentLevel'] ?? 'N3'),
          const SizedBox(height: 24),

          // 1. VIEW LEARNING PROGRESS
          _buildProgressCard((data['overallProgress'] ?? 0.0).toDouble(), data['currentLevel'] ?? 'N3'),
          const SizedBox(height: 24),

          // 2. NAVIGATE LEARNING FEATURES (Quick Access Buttons)
          _buildFeatureItem(Icons.style_rounded, 'Flashcards', Colors.purple, () {
            if (!mounted) return;

            // 🚀 Bấm phát navigate thẳng sang màn hình Dashboard luôn, không check data rườm rà nữa!
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FlashcardDashboardScreen(),
              ),
            );
          }),

          // 3. VIEW RECOMMENDED LESSONS
          _buildSectionTitle('Gợi ý học tập dành riêng cho bạn'),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendedLessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildLessonItem(recommendedLessons[index]),
          ),
          const SizedBox(height: 28),

          // 4. VIEW RECENT ACTIVITIES
          _buildSectionTitle('Hoạt động gần đây'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivities.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) => _buildActivityItem(recentActivities[index]),
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
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(level, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }

  // 1. Widget View Progress Card
  Widget _buildProgressCard(double progress, String level) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
              Text('${(progress * 100).toInt()}% Hoàn thành', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Widget Navigate Features Grid (Bao gồm Access Flashcard, Quiz, Dashboard)
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
          // 🚀 TẠM THỜI: Navigate thẳng sang trang Dashboard để load data bộ từ vựng
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FlashcardDashboardScreen(),
            ),
          );
        }),
        _buildFeatureItem(Icons.quiz_rounded, 'Online Quiz', Colors.orange, () {
          // Xử lý quiz sau
        }),
        _buildFeatureItem(Icons.analytics_rounded, 'Dashboard', Colors.teal, () {
          // Xử lý dashboard sau
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
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(Map<String, dynamic> lesson) {
    final String title = lesson['title'] ?? 'Không có tiêu đề';
    final String reason = lesson['reason'] ?? 'Gợi ý cho bạn';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(reason, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.play_circle_outline_rounded, color: Colors.blue),
        ],
      ),
    );
  }

  // 4. Widget View Recent Activities Item
  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final String action = activity['action'] ?? '';
    final String time = activity['time'] ?? '';

    return Row(
      children: [
        const Icon(Icons.history_toggle_off_rounded, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(action, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}