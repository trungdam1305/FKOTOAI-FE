/*
 * Author: trungdam
 * Servlet: TranslationScreen
 */
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

// ==========================================
// LỚP HỖ TRỢ VẼ TAY (CANVAS STROKE)
// ==========================================
class Stroke {
  final List<Offset> points = [];
  final List<int> times = [];
  int startTime = 0;
}

class HandwritingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  HandwritingPainter(this.strokes, this.currentStroke);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!, paint);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.isEmpty) return;
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// MÀN HÌNH CHÍNH
// ==========================================
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Biến cho Tra từ điển ---
  final TextEditingController _searchController = TextEditingController();
  bool _isDictLoading = false;
  String _dictErrorMessage = '';
  Map<String, dynamic>? _vocabResult;

  // --- Biến cho Dịch văn bản ---
  final TextEditingController _translateInputController = TextEditingController();
  String _sourceLang = 'ja';
  String _targetLang = 'vi';
  String _translateOutput = 'Kết quả dịch sẽ hiển thị ở đây...';
  bool _isTranslating = false;

  // --- Biến cho Dịch ảnh (OCR) ---
  File? _ocrImage;
  bool _isOcrProcessing = false;
  String _ocrOriginalText = '';
  String _ocrTranslatedText = '';
  String _ocrErrorMessage = '';

  // --- Biến cho Viết tay (Handwriting) ---
  final List<Stroke> _hwStrokes = [];
  Stroke? _hwCurrentStroke;
  Timer? _hwDebounceTimer;
  bool _isHwRecognizing = false;
  List<String> _hwCandidates = [];
  String _selectedHwCandidate = '';

  bool _isHwDictLoading = false;
  String _hwDictErrorMessage = '';
  Map<String, dynamic>? _hwDictResult;

  double _hwCanvasWidth = 300;
  double _hwCanvasHeight = 300;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _translateInputController.dispose();
    _tabController.dispose();
    _hwDebounceTimer?.cancel();
    super.dispose();
  }

  // ==========================================
  // LOGIC API: TRA TỪ ĐIỂN CHUNG
  // ==========================================
  Future<void> _handleDictSearch(String keyword, {required bool isTabDict}) async {
    if (keyword.isEmpty) return;

    if (isTabDict) {
      FocusScope.of(context).unfocus();
      setState(() { _isDictLoading = true; _dictErrorMessage = ''; _vocabResult = null; });
    } else {
      setState(() { _isHwDictLoading = true; _hwDictErrorMessage = ''; _hwDictResult = null; });
    }

    try {
      final encodedWord = Uri.encodeComponent(keyword);
      final url = Uri.parse('http://10.0.2.2:8080/FKOTOAI/api/v1/handwriting/search?studentId=1&word=$encodedWord');
      final response = await http.post(url, headers: {'Accept': '*/*'});

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['code'] == 200 && data['result'] != null) {
          final resultData = data['result']['data'] ?? data['result'];
          setState(() {
            if (isTabDict) _vocabResult = resultData;
            else _hwDictResult = resultData;
          });
        } else {
          setState(() {
            final msg = 'Không tìm thấy kết quả cho "$keyword"';
            if (isTabDict) _dictErrorMessage = msg;
            else _hwDictErrorMessage = msg;
          });
        }
      } else {
        setState(() {
          final msg = 'Lỗi kết nối HTTP: ${response.statusCode}';
          if (isTabDict) _dictErrorMessage = msg;
          else _hwDictErrorMessage = msg;
        });
      }
    } catch (e) {
      setState(() {
        final msg = 'Không thể kết nối: $e';
        if (isTabDict) _dictErrorMessage = msg;
        else _hwDictErrorMessage = msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          if (isTabDict) _isDictLoading = false;
          else _isHwDictLoading = false;
        });
      }
    }
  }

  // ==========================================
  // LOGIC API: DỊCH VĂN BẢN
  // ==========================================
  Future<void> _handleTranslate() async {
    final text = _translateInputController.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() { _isTranslating = true; _translateOutput = 'Đang dịch...'; });

    try {
      final url = Uri.parse('http://10.0.2.2:8080/FKOTOAI/api/v1/translate/text?studentId=1');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode({"text": text, "sourceLang": _sourceLang, "targetLang": _targetLang}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['code'] == 200 && data['result'] != null) {
          final translatedText = data['result']['translatedText'] ?? '';
          final romaji = data['result']['romaji'] ?? '';
          setState(() => _translateOutput = (romaji.isNotEmpty ? '🔊 $romaji\n' : '') + translatedText);
        } else {
          setState(() => _translateOutput = '❌ Lỗi từ server: ${data['message']}');
        }
      } else {
        setState(() => _translateOutput = '❌ Lỗi kết nối HTTP: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _translateOutput = '❌ Lỗi kết nối: $e');
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  // ==========================================
  // LOGIC API: DỊCH ẢNH (OCR)
  // ==========================================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _ocrImage = File(pickedFile.path); _ocrOriginalText = ''; _ocrTranslatedText = ''; _ocrErrorMessage = ''; });
    }
  }

  Future<void> _handleOcr() async {
    if (_ocrImage == null) return;
    setState(() { _isOcrProcessing = true; _ocrErrorMessage = ''; });

    try {
      final url = Uri.parse('http://10.0.2.2:8080/FKOTOAI/api/v1/ocr/recognize?studentId=1');
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', _ocrImage!.path));
      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200 && data['code'] == 200 && data['result'] != null) {
        setState(() {
          _ocrOriginalText = data['result']['originalText'] ?? '(Không nhận diện được)';
          _ocrTranslatedText = data['result']['translatedText'] ?? '(Không dịch được)';
        });
      } else {
        setState(() => _ocrErrorMessage = data['message'] ?? 'Lỗi server');
      }
    } catch (e) {
      setState(() => _ocrErrorMessage = 'Lỗi kết nối: $e');
    } finally {
      if (mounted) setState(() => _isOcrProcessing = false);
    }
  }

  // ==========================================
  // LOGIC API: VIẾT TAY (HANDWRITING)
  // ==========================================
  void _scheduleRecognition(double canvasWidth, double canvasHeight) {
    _hwDebounceTimer?.cancel();
    if (_hwStrokes.isEmpty) return;

    // Gợi ý liên tục thời gian thực sau 400ms khi ngừng bút
    _hwDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      _handleHandwritingRecognize(canvasWidth, canvasHeight, silent: true);
    });
  }

  Future<void> _handleHandwritingRecognize(double canvasWidth, double canvasHeight, {bool silent = false}) async {
    if (_hwStrokes.isEmpty) {
      if (!silent) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng vẽ ít nhất 1 nét!')));
      return;
    }

    if (!silent) {
      setState(() { _hwCandidates.clear(); _hwDictResult = null; _hwDictErrorMessage = ''; });
    }
    setState(() => _isHwRecognizing = true);

    try {
      final ink = _hwStrokes.map((s) {
        return {
          "x": s.points.map((p) => p.dx.toInt()).toList(),
          "y": s.points.map((p) => p.dy.toInt()).toList(),
          "t": s.times,
        };
      }).toList();

      final url = Uri.parse('http://10.0.2.2:8080/FKOTOAI/api/v1/handwriting/recognize?studentId=1');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode({
          "writingAreaWidth": canvasWidth.toInt(),   // dùng tham số thay vì _hwCanvasWidth
          "writingAreaHeight": canvasHeight.toInt(), // dùng tham số thay vì _hwCanvasHeight
          "ink": ink,
          "maxNumResults": 10,
          "preContext": ""
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['code'] == 200 && data['result'] != null) {
          final List cands = data['result']['candidates'] ?? [];
          setState(() {
            _hwCandidates = cands.map((e) => e.toString()).toList();
            if (_hwCandidates.isNotEmpty) {
              _selectedHwCandidate = _hwCandidates[0];
              _handleDictSearch(_selectedHwCandidate, isTabDict: false);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi nhận diện: $e');
    } finally {
      if (mounted) setState(() => _isHwRecognizing = false);
    }
  }

  // ==========================================
  // GIAO DIỆN CHÍNH (SCAFFOLD)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('FKOTOAI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tra từ điển'),
            Tab(text: 'Dịch'),
            Tab(text: 'Dịch ảnh'),
            Tab(text: 'Viết tay'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Khóa lướt ngang để không ảnh hưởng bảng vẽ
        children: [
          _buildDictionaryTab(),
          _buildTranslateTab(),
          _buildOcrTab(),
          _buildHandwritingTab(), // <-- Đã thêm Tab Viết tay
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: TRA TỪ ĐIỂN
  // ==========================================
  Widget _buildDictionaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _handleDictSearch(_searchController.text.trim(), isTabDict: true),
                    decoration: InputDecoration(
                      hintText: 'Nhập từ vựng...',
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _tabController.animateTo(3)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.green, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _handleDictSearch(_searchController.text.trim(), isTabDict: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text('Tra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['人', '猫', '勉強', '日本', 'ありがとう'].map((tag) => ActionChip(
              label: Text(tag, style: const TextStyle(color: Colors.black87, fontSize: 13)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
              onPressed: () {
                _searchController.text = tag;
                _handleDictSearch(tag, isTabDict: true);
              },
            )).toList(),
          ),
          const SizedBox(height: 24),
          _buildVocabResultUI(
            isLoading: _isDictLoading,
            errorMessage: _dictErrorMessage,
            vocabResult: _vocabResult,
            onSuggestTap: (word) {
              _searchController.text = word;
              _handleDictSearch(word, isTabDict: true);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: DỊCH VĂN BẢN
  // ==========================================
  Widget _buildTranslateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangDropdown(_sourceLang, (val) => setState(() => _sourceLang = val!)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(onTap: () => setState(() { final t = _sourceLang; _sourceLang = _targetLang; _targetLang = t; }), child: const Icon(Icons.sync_alt_rounded, color: Colors.grey)),
                ),
                _buildLangDropdown(_targetLang, (val) => setState(() => _targetLang = val!)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _translateInputController, maxLines: 5, minLines: 3,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Nhập văn bản cần dịch...', filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.green, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTranslating ? null : _handleTranslate,
              icon: _isTranslating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.autorenew_rounded, color: Colors.white),
              label: Text(_isTranslating ? 'Đang dịch...' : 'Dịch', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                child: Text(_translateOutput, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _translateOutput.startsWith('❌') ? Colors.red : Colors.green.shade700, height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangDropdown(String currentValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue, isDense: true, icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          items: const [
            DropdownMenuItem(value: 'ja', child: Text('Nhật', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: 'vi', child: Text('Việt', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: 'en', child: Text('Anh', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: 'ko', child: Text('Hàn', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: 'zh', child: Text('Trung', style: TextStyle(fontSize: 14))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: DỊCH ẢNH (OCR)
  // ==========================================
  Widget _buildOcrTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickImage, borderRadius: BorderRadius.circular(12),
              child: Container(
                height: _ocrImage == null ? 200 : null, constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: _ocrImage == null ? Colors.grey.shade300 : Colors.green.shade300, width: 2)),
                alignment: Alignment.center,
                child: _ocrImage == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.image_outlined, size: 48, color: Colors.grey), const SizedBox(height: 12), Text('Click để chọn ảnh chứa tiếng Nhật', style: TextStyle(color: Colors.grey.shade600, fontSize: 14))])
                    : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_ocrImage!, fit: BoxFit.contain)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (_ocrImage == null || _isOcrProcessing) ? null : _handleOcr,
              icon: _isOcrProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.search, color: Colors.white),
              label: Text(_isOcrProcessing ? 'Đang xử lý ảnh...' : 'Nhận diện & Dịch', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, disabledBackgroundColor: Colors.green.shade300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            ),
            const SizedBox(height: 24),
            if (_ocrErrorMessage.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text('❌ $_ocrErrorMessage', style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center)),
            if (_ocrOriginalText.isNotEmpty || _ocrTranslatedText.isNotEmpty) ...[
              Row(children: [Icon(Icons.menu_book, size: 18, color: Colors.grey.shade600), const SizedBox(width: 8), Text('Văn bản nhận diện:', style: TextStyle(fontSize: 14, color: Colors.grey.shade700))]),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: Text(_ocrOriginalText, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6))),
              const SizedBox(height: 20),
              Row(children: [Icon(Icons.g_translate, size: 18, color: Colors.green.shade600), const SizedBox(width: 8), Text('Bản dịch:', style: TextStyle(fontSize: 14, color: Colors.grey.shade700))]),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: Text(_ocrTranslatedText, style: TextStyle(fontSize: 16, color: Colors.teal.shade800, height: 1.5, fontWeight: FontWeight.w500))),
            ]
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 4: VIẾT TAY (HANDWRITING)
  // ==========================================
  Widget _buildHandwritingTab() {
    // 1. Lấy chiều rộng màn hình khả dụng
    final double screenWidth = MediaQuery.of(context).size.width;
    // Trừ đi padding (16 + 16 = 32)
    final double canvasWidth = screenWidth - 32;
    const double canvasHeight = 300.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      // 2. Ép buộc chiều rộng cho nội dung bên trong để tránh lỗi vô tận
      child: SizedBox(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Khu vực vẽ tay (Đã cố định kích thước)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: canvasHeight,
                      width: canvasWidth,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          _hwDebounceTimer?.cancel();
                          _hwCurrentStroke = Stroke()..startTime = DateTime.now().millisecondsSinceEpoch;
                          _hwCurrentStroke!.points.add(details.localPosition);
                          _hwCurrentStroke!.times.add(0);
                          setState(() {});
                        },
                        onPanUpdate: (details) {
                          if (_hwCurrentStroke != null) {
                            _hwCurrentStroke!.points.add(details.localPosition);
                            _hwCurrentStroke!.times.add(DateTime.now().millisecondsSinceEpoch - _hwCurrentStroke!.startTime);
                            setState(() {});
                          }
                        },
                        onPanEnd: (details) {
                          if (_hwCurrentStroke != null) {
                            _hwStrokes.add(_hwCurrentStroke!);
                            _hwCurrentStroke = null;
                            setState(() {});
                            // Gọi hàm nhận diện với thông số canvas chuẩn
                            _scheduleRecognition(canvasWidth, canvasHeight);
                          }
                        },
                        child: CustomPaint(
                          painter: HandwritingPainter(_hwStrokes, _hwCurrentStroke),
                          size: Size(canvasWidth, canvasHeight),
                        ),
                      ),
                    ),
                  ),

                  // Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => setState(() {
                            _hwStrokes.clear();
                            _hwCandidates.clear();
                            _hwDictResult = null;
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo, color: Colors.blue),
                          onPressed: () {
                            if (_hwStrokes.isNotEmpty) {
                              setState(() => _hwStrokes.removeLast());
                              _scheduleRecognition(canvasWidth, canvasHeight);
                            }
                          },
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _handleHandwritingRecognize(canvasWidth, canvasHeight, silent: false),
                          icon: const Icon(Icons.search, color: Colors.white, size: 18),
                          label: const Text('Nhận diện', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Gợi ý từ
            if (_hwCandidates.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _hwCandidates.map((cand) => ActionChip(
                  label: Text(cand, style: TextStyle(color: cand == _selectedHwCandidate ? Colors.green : Colors.black87)),
                  onPressed: () => setState(() => _selectedHwCandidate = cand),
                )).toList(),
              ),
            ],

            const SizedBox(height: 16),
            _buildVocabResultUI(
              isLoading: _isHwDictLoading,
              errorMessage: _hwDictErrorMessage,
              vocabResult: _hwDictResult,
              onSuggestTap: (word) => _handleDictSearch(word, isTabDict: false),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HÀM TIỆN ÍCH DÙNG CHUNG: HIỂN THỊ KẾT QUẢ TỪ ĐIỂN
  // ==========================================
  Widget _buildVocabResultUI({
    required bool isLoading,
    required String errorMessage,
    required Map<String, dynamic>? vocabResult,
    required Function(String) onSuggestTap,
  }) {
    if (isLoading) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Colors.green)));
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(errorMessage, style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    if (vocabResult != null && (vocabResult['words'] as List? ?? []).isNotEmpty) {
      final List words = vocabResult['words'];
      final List suggestWords = vocabResult['suggestWords'] ?? [];
      final entry = words[0];

      final word = entry['word'] ?? '';
      final phonetic = entry['phonetic'] ?? '';
      final hanViet = entry['hanViet'] ?? entry['kanji'] ?? '(Chưa cập nhật)';
      final levels = entry['level'] as List? ?? [];
      final level = levels.isNotEmpty ? levels[0].toString() : '';
      final means = entry['means'] as List? ?? [];

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: Colors.black87, height: 1.2)),
                  const SizedBox(height: 8),
                  if (level.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                          color: level.toLowerCase().contains('n5') ? Colors.green.shade50 : (level.toLowerCase().contains('n4') ? Colors.purple.shade50 : Colors.blue.shade50),
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(level.toUpperCase(), style: TextStyle(
                          color: level.toLowerCase().contains('n5') ? Colors.green.shade700 : (level.toLowerCase().contains('n4') ? Colors.purple.shade700 : Colors.blue.shade700),
                          fontSize: 11, fontWeight: FontWeight.w700)
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    children: [
                      if (phonetic.isNotEmpty) Text(phonetic, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
                      Text('Hán-Việt: $hanViet', style: TextStyle(fontSize: 15, color: Colors.orange.shade700, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            if (means.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: means.map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('→', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                                children: [
                                  TextSpan(text: m['mean'] ?? ''),
                                  if ((m['kind'] ?? '').isNotEmpty) TextSpan(text: '  (${m['kind']})', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (suggestWords.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gợi ý (${suggestWords.length})', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: suggestWords.length,
                      itemBuilder: (context, index) {
                        final s = suggestWords[index];
                        return InkWell(
                          onTap: () => onSuggestTap(s['word'] ?? ''),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s['word'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                      if ((s['phonetic'] ?? '').isNotEmpty)
                                        Padding(padding: const EdgeInsets.only(top: 2.0), child: Text(s['phonetic'], style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 6,
                                  child: Text(s['short_mean'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4), textAlign: TextAlign.right),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}