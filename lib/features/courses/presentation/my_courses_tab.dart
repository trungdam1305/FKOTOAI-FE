import 'package:flutter/material.dart';
import '../data/courses_models.dart';
import '../data/courses_api_service.dart';

class MyCoursesTab extends StatefulWidget {
  const MyCoursesTab({Key? key}) : super(key: key);

  @override
  State<MyCoursesTab> createState() => _MyCoursesTabState();
}

class _MyCoursesTabState extends State<MyCoursesTab> {
  final Color primaryBlue = const Color(0xFF3B40E8);
  final Color textBlack = const Color(0xFF2D2D2D); // Đen mềm
  final Color textGrey = const Color(0xFF757575);
  final Color bgCard = const Color(0xFFF8F9FA); // Nền xám giấy
  final Color borderColor = Colors.grey.shade200;

  final CoursesApiService _apiService = CoursesApiService();
  late Future<List<EnrolledCourse>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _apiService.fetchMyCourses();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<EnrolledCourse>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryBlue));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải khóa học', style: TextStyle(fontFamily: 'Nunito', color: textBlack)));
          }

          final List<EnrolledCourse> courses = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 40),
            children: [
              _buildSectionTitle('Hành trình của bạn', Icons.map_outlined, Colors.orange.shade600),
              const SizedBox(height: 20),

              ...courses.map((course) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildFlatCourseCard(course),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito', letterSpacing: 0.3),
        ),
      ],
    );
  }

  Widget _buildFlatCourseCard(EnrolledCourse course) {
    int percentView = (course.progressPercent * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72, height: 72,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.network(course.imageUrl, fit: BoxFit.contain),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito')),
                    const SizedBox(height: 4),
                    Text(course.subtitle, style: TextStyle(fontSize: 14, color: textGrey, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: course.progressPercent,
                              minHeight: 6, // Thanh mỏng thanh lịch
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('$percentView%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primaryBlue, fontFamily: 'Nunito')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue.withOpacity(0.1),
                foregroundColor: primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Pill shape
              ),
              child: const Text('Tiếp tục học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
            ),
          ),
        ],
      ),
    );
  }
}