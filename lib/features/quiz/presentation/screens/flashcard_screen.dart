import 'package:flutter/material.dart';

import 'package:bim/core/theme/app_colors.dart';

class FlashcardScreen extends StatefulWidget {
  final String title;
  final List<dynamic> flashcards;

  const FlashcardScreen({
    super.key,
    required this.title,
    required this.flashcards,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.flashcards[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.midnightBlue,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [

          const SizedBox(height: 20),

          Text(
            "${_currentIndex + 1}/${widget.flashcards.length}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: _showAnswer
                          ? _buildBack(card)
                          : _buildFront(card),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _showAnswer
                  ? "Chạm vào thẻ để xem mặt trước"
                  : "Chạm vào thẻ để xem nghĩa",
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                    _currentIndex == 0 ? null : _previousCard,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Trước"),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                    _currentIndex ==
                        widget.flashcards.length - 1
                        ? null
                        : _nextCard,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Tiếp"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFront(dynamic card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Text(
          card["word"] ?? "",
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          card["word_type"] ?? "",
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 20),

        if (card["kanji_meaning"] != null)
          Text(
            card["kanji_meaning"],
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

        const SizedBox(height: 40),

        const Icon(
          Icons.touch_app,
          color: Colors.grey,
        ),

        const SizedBox(height: 8),

        const Text(
          "Chạm để xem nghĩa",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBack(dynamic card) {
    final examples = card["example"] ?? [];
    final meanings = card["meaning_example"] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          card["word"] ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          card["meaning"] ?? "",
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "Ví dụ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 10),

        ...List.generate(examples.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  examples[index]["example"]
                      .toString()
                      .replaceAll(RegExp(r'<[^>]*>'), ''),
                ),

                if (index < meanings.length)
                  Text(
                    meanings[index]
                        .toString()
                        .replaceAll(RegExp(r'<[^>]*>'), ''),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}