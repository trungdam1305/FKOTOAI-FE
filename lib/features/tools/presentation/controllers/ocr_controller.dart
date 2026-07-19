import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/repositories/ocr_repository.dart';

class OcrController extends ChangeNotifier {
  final OcrRepository repository;

  OcrController({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> get results => _results;

  Future<void> scanAndLookupWord(File imageFile, String token, [String studentId = '']) async {
    _isLoading = true;
    _errorMessage = '';
    _results = [];
    notifyListeners();

    try {
      final data = await repository.lookupImage(imageFile, token, studentId);
      _results = data;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _results = [];
    _errorMessage = '';
    notifyListeners();
  }
}