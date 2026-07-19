abstract class CourseRepository {
  Future<List<Map<String, dynamic>>> getCourses();
  Future<Map<String, dynamic>> getCourseDetail(String slug);
}
