import 'package:flutter/material.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/authentication/presentation/screens/login_screen.dart';
import 'package:bim/features/home/presentation/screens/student_home_screen.dart';
import 'package:bim/features/profile/presentation/screens/profile_screen.dart';
import 'package:bim/features/quiz/presentation/screens/course_list_screen.dart';
import 'package:bim/features/flashcard/presentation/screens/VocabularyChapterScreen.dart';

import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/gradient_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final _authController = AuthController();

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const VocabularyChapterScreen(),
    const CourseListScreen(),
    const ProfileTab(),
  ];

  void _handleLogout() async {
    final token = await _authLocalDataSource.getToken();
    if (token == null) return _navigateToLogin();

    _authController.logout(
      token: token,
      onLoading: () => setState(() => _isLoggingOut = true),
      onSuccess: () async {
        await _authLocalDataSource.deleteToken();
        if (mounted) _navigateToLogin();
      },
      onError: (e) => setState(() => _isLoggingOut = false),
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: _selectedIndex == 0
            ? AppBar(
          backgroundColor: AppColors.midnightBlue,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/lo.png', height: 40, width: 40, fit: BoxFit.contain),
              const SizedBox(width: 10),
              const Text('FKOTOAI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          actions: [
            _isLoggingOut
                ? const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _handleLogout),
          ],
        )
            : null,

        body: IndexedStack(index: _selectedIndex, children: _screens),

        bottomNavigationBar: isDesktop ? null : _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white.withOpacity(0.9),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.flash_on_outlined), label: 'Flashcards'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Khóa học'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}