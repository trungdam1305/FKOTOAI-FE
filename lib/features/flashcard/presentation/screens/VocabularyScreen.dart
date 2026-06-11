import 'package:flutter/material.dart';
import 'dart:math';

class VocabularyScreen extends StatefulWidget {
  final List<dynamic> flashcards;

  const VocabularyScreen({super.key, required this.flashcards});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isFinished ? _buildFinishScreen() : _buildLearningScreen(),
    );
  }

  Widget _buildLearningScreen() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.flashcards.length,
            itemBuilder: (context, index) => Center(child: FlashcardItem(card: widget.flashcards[index])),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.purple),
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              ),
              Text("${_currentIndex + 1}/${widget.flashcards.length}", style: const TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                onPressed: () {
                  if (_currentIndex < widget.flashcards.length - 1) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    setState(() => _isFinished = true);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinishScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 20),
          const Text("Tiến độ của bạn", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            width: 320,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Hoàn thành", style: TextStyle(color: Colors.black54)), Text("${widget.flashcards.length}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 15),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Còn lại", style: TextStyle(color: Colors.black54)), Text("0", style: TextStyle(color: Colors.black))]),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
            onPressed: () {},
            child: const Text("Ôn luyện với các câu hỏi", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => setState(() => _isFinished = false),
            child: const Text("← Quay lại câu hỏi cuối cùng", style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }
}


class FlashcardItem extends StatefulWidget {
  final Map<String, dynamic> card;
  const FlashcardItem({super.key, required this.card});

  @override
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem> {
  bool _isFront = true;
  double _angle = 0;

  void _flipCard() {
    setState(() {
      _angle = (_angle + pi) % (2 * pi);
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: _angle),
        duration: const Duration(milliseconds: 500),
        builder: (context, double val, child) {
          final isUnder = val >= (pi / 2);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(val),
            child: isUnder
                ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(pi),
              child: _buildCardContent(isBack: true),
            )
                : _buildCardContent(isBack: false),
          );
        },
      ),
    );
  }

  Widget _buildCardContent({required bool isBack}) {
    return Container(
      width: 320, height: 450,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isBack ? "Nghĩa" : "Từ vựng", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 10),
              Text(isBack ? widget.card['meaning'] : widget.card['word'],
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              if (!isBack && widget.card['reading'] != null)
                Text(widget.card['reading'], style: const TextStyle(fontSize: 20, color: Colors.purple)),
            ],
          ),
        ),
      ),
    );
  }
}