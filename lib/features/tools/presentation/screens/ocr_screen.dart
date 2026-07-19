import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bim/features/authentication/data/auth_local_data_source.dart';
import 'package:bim/features/tools/data/reporitories/ocr_repository_impl.dart';
import 'package:bim/features/tools/presentation/controllers/ocr_controller.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({Key? key}) : super(key: key);

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  late final OcrController _controller;
  final AuthLocalDataSource _localDataSource = AuthLocalDataSource();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final Color primaryBlue = const Color(0xFF3B40E8);
  final Color textBlack = const Color(0xFF2D2D2D);
  final Color textGrey = const Color(0xFF757575);
  final Color borderColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _controller = OcrController(repository: OcrRepositoryImpl());
  }

  TextStyle _txt({double size = 14, FontWeight weight = FontWeight.w600, bool isGrey = false}) {
    return TextStyle(fontSize: size, fontWeight: weight, color: isGrey ? textGrey : textBlack, fontFamily: 'Nunito');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print("[OCR Screen] Bắt đầu chọn ảnh từ: ${source.toString()}");
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        print("[OCR Screen] Chọn ảnh thành công: ${pickedFile.path}");
        setState(() {
          _image = File(pickedFile.path);
        });
        _controller.clearResults();
        _uploadAndLookup();
      } else {
        print("[OCR Screen] Người dùng đã hủy chọn ảnh.");
      }
    } catch (e) {
      print("[OCR Screen] Lỗi khi chọn ảnh: $e");
    }
  }

  Future<void> _uploadAndLookup() async {
    if (_image == null) {
      print("[OCR Screen] Hủy thực hiện gửi API do chưa có file ảnh.");
      return;
    }

    print("[OCR Screen] Đang đọc token từ local storage...");
    final token = await _localDataSource.getToken();

    if (token == null || token.isEmpty) {
      print("[OCR Screen] Lỗi: Token trống hoặc đã hết hạn.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phiên đăng nhập hết hạn!', style: _txt(isGrey: true))),
      );
      return;
    }

    print("[OCR Screen] Khởi chạy scanAndLookupWord. Khởi tạo request gửi lên Server.");
    await _controller.scanAndLookupWord(_image!, token, '');

    if (_controller.errorMessage.isNotEmpty) {
      print("[OCR Screen] Xử lý thất bại. Message lỗi từ Controller: ${_controller.errorMessage}");
    } else {
      print("[OCR Screen] Xử lý thành công. Số lượng từ vựng lấy về: ${_controller.results.length}");
      print("[OCR Screen] Chi tiết Data: ${_controller.results.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tra từ qua Camera', style: _txt(size: 20, weight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: _image == null
                    ? Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Icon(Icons.camera_alt_outlined, size: 70, color: textGrey),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(_image!, width: 250, height: 250, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt_rounded, color: textBlack, size: 18),
                    label: Text('Chụp ảnh', style: _txt(size: 14, weight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      side: BorderSide(color: borderColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library_rounded, color: textBlack, size: 18),
                    label: Text('Chọn ảnh', style: _txt(size: 14, weight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      side: BorderSide(color: borderColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              Expanded(
                child: _controller.isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryBlue))
                    : _controller.errorMessage.isNotEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(_controller.errorMessage, style: _txt(isGrey: true), textAlign: TextAlign.center),
                  ),
                )
                    : _controller.results.isEmpty
                    ? Center(child: Text('Chưa có dữ liệu tra cứu', style: _txt(isGrey: true)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: _controller.results.length,
                  itemBuilder: (context, index) {
                    final item = _controller.results[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['word'] ?? ''} [${item['hiragana'] ?? ''}]',
                                  style: _txt(size: 16, weight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['meaning'] ?? '',
                                  style: _txt(size: 13, isGrey: true),
                                ),
                              ],
                            ),
                          ),
                          if (item['level'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['level'],
                                style: TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.w800, fontFamily: 'Nunito'),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}