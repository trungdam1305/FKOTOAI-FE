import 'package:flutter/material.dart';
// Import màn hình LoginScreen từ thư mục presentation của bạn
import 'package:bim/features/authentication/presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bim App',
      // Tắt cái banner "DEBUG" màu đỏ ở góc phải màn hình cho đẹp
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Cấu hình ứng dụng chạy thẳng vào màn hình Login đầu tiên
      home: const LoginScreen(),
    );
  }
}