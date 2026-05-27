import 'package:flutter/material.dart';
// TODO: Thay đổi đường dẫn import này cho khớp với thư mục của bạn
import '../home/presentation/home_tab.dart';
import '../courses/presentation/my_courses_tab.dart';
import '../profile/presentation/profile_tab.dart';
import '../quiz/presentation/quiz_tab.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color primaryBlue = const Color(0xFF3B40E8);
  int _selectedIndex = 0;

  // Danh sách các màn hình đã được tách file
  final List<Widget> _screens = [
    const HomeTab(), // Tab 0: Home
    const QuizTab(),
    const MyCoursesTab(), // Tab 2: Khóa học
    const ProfileTab(), // Tab 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      // Giữ nguyên trạng thái bằng IndexedStack
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 22, height: 2.5, decoration: BoxDecoration(color: const Color(0xFF4A4A4A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 5),
            Container(width: 14, height: 2.5, decoration: BoxDecoration(color: const Color(0xFF4A4A4A), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 5),
            Container(width: 22, height: 2.5, decoration: BoxDecoration(color: const Color(0xFF4A4A4A), borderRadius: BorderRadius.circular(2))),
          ],
        ),
        onPressed: () {},
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryBlue.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(Icons.menu_book_rounded, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Quicksand', fontSize: 24),
              children: [
                TextSpan(text: 'Fkoto', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                const TextSpan(text: ' AI', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 1.5)),

          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1))),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: primaryBlue,
        unselectedItemColor: const Color(0xFF4A4A4A),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined, size: 28), activeIcon: Icon(Icons.emoji_events), label: 'Thi đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill, size: 28), label: 'Khóa học'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Profile'),
        ],
      ),
    );
  }
}