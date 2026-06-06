import 'package:flutter/material.dart';

abstract class HomeRepository {
  Future<Map<String, dynamic>> getDashboardData(String token);
}