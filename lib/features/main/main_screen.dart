import 'package:flutter/material.dart';
import '../home/presentation/screens/student_home_screen.dart';
import 'package:bim/features/profile/presentation/screens/profile_screen.dart';
import '../quiz/presentation/quiz_tab.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:bim/features/authentication/presentation/screens/login_screen.dart';
import 'package:bim/features/flashcard/presentation/screens/VocabularyChapterScreen.dart';
import 'package:bim/features/flashcard/presentation/screens/flashcard_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color primaryBlue = const Color(0xFF3B40E8);
  int _selectedIndex = 0;

  final _authController = AuthController();
  bool _isLoggingOut = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    _authController.logout(
      onLoading: () => setState(() => _isLoggingOut = true),
      onSuccess: () {
        setState(() => _isLoggingOut = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng xuất thành công!'), backgroundColor: Colors.blue),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      },
      onError: (error) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const StudentHomeScreen(),
      VocabularyChapterScreen(
        onExitPressed: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      const QuizTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FKOTOAI'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _isLoggingOut
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
          BottomNavigationBarItem(icon: Icon(Icons.flash_on_rounded, size: 28), label: 'Flashcards'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined, size: 28), activeIcon: Icon(Icons.emoji_events), label: 'Thi đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Profile'),
        ],
      ),
    );
  }
}