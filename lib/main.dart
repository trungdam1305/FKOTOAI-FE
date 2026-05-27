import 'package:flutter/material.dart';
// TODO: Thay đường dẫn này đến file main_screen.dart của bạn
import '../features/main/main_screen.dart';

void main() {
  runApp(const NihongoApp());
}

class NihongoApp extends StatelessWidget {
  const NihongoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ thống học tiếng Nhật N5/N4',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Quicksand', // Thiết lập font
      ),
      home: const MainScreen(), // Điểm bắt đầu là file Điều hướng chính
      debugShowCheckedModeBanner: false,
    );
  }
}