import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:bim/core/theme/app_colors.dart';

class PDFViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const PDFViewerScreen({super.key, required this.filePath, required this.title});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: AppColors.midnightBlue,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          if (_isReady && _totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.WIDTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
              print("Lỗi render PDF: $error");
            },
            onPageError: (page, error) {
              print("Lỗi tại trang $page: $error");
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
              });
            },
          ),

          if (!_isReady && _errorMessage.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Đang mở tài liệu...',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  )
                ],
              ),
            ),

          if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Không thể hiển thị tài liệu này.\nĐịnh dạng file lỗi hoặc hỏng.',
                  style: TextStyle(color: Colors.red[300], fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}