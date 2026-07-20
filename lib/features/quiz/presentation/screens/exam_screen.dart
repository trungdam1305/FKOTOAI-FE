import 'package:flutter/material.dart';
import 'package:bim/core/theme/app_colors.dart';

class ExamScreen extends StatefulWidget {
  final String title;
  final List<dynamic> questions;

  const ExamScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int current = 0;
  int score = 0;
  bool answered = false;
  int? selected;

  Map<String, dynamic> get q => widget.questions[current];

  Future<void> choose(int index) async {
    if (answered) return;

    setState(() {
      answered = true;
      selected = index;

      if (index == q["correct"]) {
        score++;
      }
    });
    await Future.delayed(const Duration(seconds: 20));

    if (!mounted) return;

    if (current < widget.questions.length - 1) {
      setState(() {
        current++;
        answered = false;
        selected = null;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Hoàn thành"),
          content: Text(
            "Bạn đúng $score/${widget.questions.length} câu",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // đóng dialog
                Navigator.pop(context); // về màn course
              },
              child: const Text("Đóng"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  current = 0;
                  score = 0;
                  answered = false;
                  selected = null;
                });
              },
              child: const Text("Làm lại"),
            ),
          ],
        );
      },
    );
  }

  void next() {
    if (current == widget.questions.length - 1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Hoàn thành"),
          content: Text(
              "Điểm của bạn: $score/${widget.questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Đóng"),
            )
          ],
        ),
      );
      return;
    }

    setState(() {
      current++;
      answered = false;
      selected = null;
    });
  }

  Color optionColor(int i) {
    if (!answered) return Colors.white;

    if (i == q["correct"]) {
      return Colors.green.shade200;
    }

    if (i == selected) {
      return Colors.red.shade200;
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final List options = q["options"] ?? [];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
        title: Text(widget.title),
      ),
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

            LinearProgressIndicator(
              value: (current + 1) / widget.questions.length,
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Câu ${current + 1}/${widget.questions.length}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              q["question"] ?? "",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            ...List.generate(options.length, (i) {
              return Card(
                color: optionColor(i),
                child: ListTile(
                  title: Text(options[i]),
                  onTap: () => choose(i),
                ),
              );
            }),

            if (answered) ...[
              const SizedBox(height: 20),

              if ((q["explain"] ?? "").toString().isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(q["explain"]),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: next,
                child: Text(
                  current == widget.questions.length - 1
                      ? "Hoàn thành"
                      : "Câu tiếp",
                ),
              )
            ]
          ],
        ),
      ),
            ),
        ),
    );
  }
}