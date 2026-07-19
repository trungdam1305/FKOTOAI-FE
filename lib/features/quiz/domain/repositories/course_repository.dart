import 'package:flutter/material.dart';

abstract class CourseRepository {
  Future<List<dynamic>> getCourses(String token);
}