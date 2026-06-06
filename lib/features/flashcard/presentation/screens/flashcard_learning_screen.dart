import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardLearningScreen extends StatefulWidget {
  final List flashcards;
  final VoidCallback? onExitPressed;

  const FlashcardLearningScreen({
    super.key,
    required this.flashcards,
    this.onExitPressed
  });

  @override
  State<FlashcardLearningScreen> createState() => _FlashcardLearningScreenState();
}

class _FlashcardLearningScreenState extends State<FlashcardLearningScreen> {
  int _currentIndex = 0;
  bool _isFront = true;

  void _nextCard(String actionType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(actionType == 'mastered' ? '🎉 Đã nhớ từ này!' : '📚 Sẽ ôn lại sau!'),
        duration: const Duration(milliseconds: 500),
      ),
    );

    setState(() {
      if (_currentIndex < widget.flashcards.length - 1) {
        _currentIndex++;
        _isFront = true;
      } else {
        _showFinishedDialog();
      }
    });
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành! 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Chúc mừng bạn đã học hết các từ vựng trong bộ Flashcard này.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _isFront = true;
              });
            },
            child: const Text('Học lại', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.pop(context);
            },
            child: const Text('Thoát', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Học Flashcard')),
        body: const Center(child: Text('Bộ thẻ này chưa có từ vựng nào.')),
      );
    }

    final currentCard = widget.flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Thẻ ${_currentIndex + 1}/${widget.flashcards.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFront = !_isFront),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
                      return AnimatedBuilder(
                        animation: rotateAnim,
                        child: child,
                        builder: (context, widgetChild) {
                          final isUnder = (ValueKey(_isFront) != widgetChild!.key);
                          var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                          tilt *= isUnder ? -1.0 : 1.0;
                          final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                          return Transform(
                            transform: Matrix4.rotationY(value)..setEntry(3, 2, tilt),
                            alignment: Alignment.center,
                            child: widgetChild,
                          );
                        },
                      );
                    },
                    child: _isFront ? _buildFrontCard(currentCard) : _buildBackCard(currentCard),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _nextCard('not_mastered'),
                      icon: const Icon(Icons.close_rounded, color: Colors.red),
                      label: const Text('Chưa thuộc', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _nextCard('mastered'),
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: const Text('Đã thuộc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> card) {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(card['furigana'] ?? '', style: const TextStyle(fontSize: 18, color: Colors.grey, letterSpacing: 2)),
          const SizedBox(height: 12),
          Text(card['word'] ?? '', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(card['romaji'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 32),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Colors.blue, size: 36),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔊 Đang phát âm thanh mẫu...'), duration: Duration(milliseconds: 400)),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text('Chạm để xem nghĩa', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBackCard(Map<String, dynamic> card) {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Ý NGHĨA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(card['meaning'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('(${card['type'] ?? 'Từ loại'})', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.blueGrey.withOpacity(0.2)),
          ),
          const Text('VÍ DỤ MẪU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(card['example_jp'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(card['example_vi'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}