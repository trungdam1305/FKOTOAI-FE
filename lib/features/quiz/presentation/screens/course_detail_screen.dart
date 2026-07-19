import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bim/core/constants/api_constants.dart';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/gradient_background.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/quiz/presentation/screens/video_player_screen.dart';
import 'package:bim/features/quiz/presentation/screens/pdf_viewer_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String slug;

  const CourseDetailScreen({super.key, required this.slug});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  Map<String, dynamic>? _courseData;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourseDetail();
  }

  Future<void> _fetchCourseDetail() async {
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

      final String dynamicUrl = '${ApiConstants.baseUrl}/api/v1/courses/${widget.slug}';

      final response = await http.get(
        Uri.parse(dynamicUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          if (data['code'] == 200 && data['result'] != null) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _courseData = data['result'] as Map<String, dynamic>;
              });
            }
            return;
          } else {
            throw Exception(data['message'] ?? 'Tải nội dung khóa học thất bại!');
          }
        }
        throw Exception('Dữ liệu khóa học từ server trống rỗng!');
      } else {
        throw Exception('Không thể tải chi tiết khóa học (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi hệ thống: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = _courseData?['name']?.toString() ?? 'Chi tiết khóa học';

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.midnightBlue,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchCourseDetail,
            )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _fetchCourseDetail,
              child: const Text('Thử tải lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_courseData == null) {
      return const Center(
        child: Text('Không có dữ liệu hiển thị.', style: TextStyle(color: Colors.white70)),
      );
    }

    final List<dynamic> categories = _courseData!['categories'] ?? [];

    if (categories.isEmpty) {
      return const Center(
        child: Text('Khóa học này hiện chưa có nội dung bài học.', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final List<dynamic> groups = category['groups'] ?? [];

        return Card(
          color: Colors.white.withOpacity(0.92),
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          child: ExpansionTile(
            iconColor: AppColors.primary,
            collapsedIconColor: Colors.black87,
            textColor: AppColors.primary,
            collapsedTextColor: Colors.black87,
            title: Text(
              category['title']?.toString() ?? category['name']?.toString() ?? 'Danh mục không tên',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            children: groups.map<Widget>((group) {
              final List<dynamic> lessons = group['lessons'] ?? [];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name']?.toString() ?? 'Nhóm bài học',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14),
                    ),
                    const SizedBox(height: 4),

                    ...lessons.map<Widget>((lesson) {
                      final String type = lesson['type']?.toString() ?? 'video';
                      final bool isDocs = type == 'docs';

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isDocs ? Icons.description : Icons.play_circle_outline,
                          color: isDocs ? Colors.amber[800] : AppColors.primary,
                          size: 22,
                        ),
                        title: Text(
                          lesson['name']?.toString() ?? 'Bài học',
                          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          isDocs ? 'Tài liệu PDF' : 'Thời lượng: ${lesson['expect_time'] ?? 0} phút',
                          style: const TextStyle(color: Colors.black54, fontSize: 11),
                        ),
                        onTap: () async {
                          final String lessonName = lesson['name']?.toString() ?? 'Bài học';

                          if (isDocs) {
                            final List<dynamic> docs = lesson['documents'] ?? [];
                            String fileName = '';
                            if (docs.isNotEmpty && docs[0]['value'] != null) {
                              fileName = docs[0]['value'].toString();
                            }

                            if (fileName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Không tìm thấy tên file tài liệu trong hệ thống!')),
                              );
                              return;
                            }

                            final String pdfUrl = 'https://dungmori.com/cdn/lesson/document/$fileName';

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đang tải tài liệu: $lessonName...'), duration: const Duration(seconds: 2)),
                            );

                            try {
                              final io.Directory tempDir = await getTemporaryDirectory();
                              final String localPath = '${tempDir.path}/$fileName';

                              await Dio().download(
                                pdfUrl,
                                localPath,
                                options: Options(
                                  headers: {
                                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                                    'Referer': 'https://dungmori.com/',
                                  },
                                ),
                              );

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PDFViewerScreen(filePath: localPath, title: lessonName),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi tải file: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          } else {
                            final String? videoUrl = lesson['video_url']?.toString() ?? lesson['stream_url']?.toString();

                            if (videoUrl != null) {
                              final String playUrl = videoUrl.startsWith('http') ? videoUrl : '${ApiConstants.baseUrl}$videoUrl';

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    url: playUrl,
                                    title: lessonName,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bài học này không có dữ liệu video!')),
                              );
                            }
                          }
                        },
                      );
                    }),
                    const Divider(color: Colors.black12),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}