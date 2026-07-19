import 'package:flutter/material.dart';
import 'package:bim/features/quiz/presentation/controller/course_controller.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/gradient_background.dart';
import 'package:bim/features/quiz/presentation/screens/course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  final VoidCallback? onExitPressed;

  const CourseListScreen({super.key, this.onExitPressed});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CourseController _courseController = CourseController();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  List<dynamic>? _coursesData;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoursesData();
  }

  Future<void> _fetchCoursesData() async {
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

      _courseController.loadCourses(
        token: userToken,
        onLoading: () {},
        onSuccess: (data) => setState(() {
          _isLoading = false;
          _coursesData = data;
        }),
        onError: (error) => setState(() {
          _isLoading = false;
          _errorMessage = error;
        }),
      );
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
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.midnightBlue,
          title: const Text('FKOTOAI — Khóa học', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: widget.onExitPressed ?? () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchCoursesData,
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
              onPressed: _fetchCoursesData,
              child: const Text('Thử tải lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_coursesData == null || _coursesData!.isEmpty) {
      return const Center(
        child: Text('Không có khóa học nào hiển thị.', style: TextStyle(color: Colors.white70)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📚 Khóa học',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 4),
          Text(
            'Học tiếng Nhật online — ${_coursesData!.length} khóa học',
            style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
          ),
          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemCount: _coursesData!.length,
            itemBuilder: (context, index) {
              final course = _coursesData![index];
              final String courseSlug = course['slug']?.toString() ??
                  course['SEOurl']?.toString() ??
                  course['code']?.toString() ?? '';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD6EAF8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF90E0EF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.folder, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      course['name']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueAccent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      courseSlug,
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          final String currentSlug = course['slug']?.toString() ??
                              course['SEOurl']?.toString() ??
                              course['code']?.toString() ?? '';

                          if (currentSlug.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailScreen(slug: currentSlug),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Không tìm thấy mã định danh của khóa học này!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Xem chi tiết →',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}