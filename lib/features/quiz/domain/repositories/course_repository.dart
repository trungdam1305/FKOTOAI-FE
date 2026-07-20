import 'package:flutter/material.dart';

abstract class CourseRepository {
  Future<List<dynamic>> getCourses(String token);

  Future<Map<String, dynamic>> getCourseDetail(
      String token,
      String slug,
      );
}