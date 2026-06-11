import 'package:flutter/material.dart';
import '../home/presentation/screens/student_home_screen.dart';
import 'package:bim/features/profile/presentation/screens/profile_screen.dart';
import '../quiz/presentation/quiz_tab.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:bim/features/authentication/presentation/screens/login_screen.dart';
import 'package:bim/features/flashcard/presentation/screens/VocabularyChapterScreen.dart';
import 'package:bim/features/flashcard/presentation/screens/flashcard_dashboard_screen.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/authentication/presentation/screens/login_screen.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color primaryBlue = const Color(0xFF3B40E8);
  int _selectedIndex = 0;
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final _authController = AuthController();
  bool _isLoggingOut = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() async {

    final String? token = await _authLocalDataSource.getToken();

    if (token == null || token.isEmpty) {
      _navigateToLogin();
      return;
    }

    _authController.logout(
      token: token,
      onLoading: () => setState(() => _isLoggingOut = true),
      onSuccess: () async {
        setState(() => _isLoggingOut = false);

        await _authLocalDataSource.deleteToken();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng xuất thành công!'), backgroundColor: Colors.blue),
        );

        _navigateToLogin();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    final List<Widget> screens = [
      const StudentHomeScreen(),
      VocabularyChapterScreen(onExitPressed: () => setState(() => _selectedIndex = 0)),
      const QuizTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/lo.png', height: 60, width: 60, fit: BoxFit.contain),
            const SizedBox(width: 10),
            const Text('FKOTOAI'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _isLoggingOut
              ? const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
              : IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _handleLogout),
        ],
      ),
      body: isDesktop
          ? Row(
        children: [
          _buildNavigationRail(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: IndexedStack(index: _selectedIndex, children: screens)),
        ],
      )
          : IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
      selectedIconTheme: IconThemeData(color: primaryBlue),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.flash_on_rounded), label: Text('Flashcards')),
        NavigationRailDestination(icon: Icon(Icons.emoji_events), label: Text('Thi đấu')),
        NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1))),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: const Color(0xFF4A4A4A),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on_rounded, size: 28), label: 'Flashcards'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events, size: 28), label: 'Thi đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Profile'),
        ],
      ),
    );
  }
}