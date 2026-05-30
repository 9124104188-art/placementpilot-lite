import 'package:flutter/material.dart';
import 'coding_question_card.dart';
import 'coding_editor_preview.dart';
import '../models/coding_question.dart'; // adjust if your path differs

class CodingSplitScreen extends StatelessWidget {
  final CodingQuestion question;
  const CodingSplitScreen({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 750;
    return Scaffold(
      appBar: AppBar(title: const Text('Coding Arena')),
      body: isWide
          ? Row(
              children: [
                // Left: Question Card
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CodingQuestionCard(question: question),
                  ),
                ),
                // Right: Code Editor + Run Button
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey[850],
                    padding: const EdgeInsets.all(24),
                    child: const CodingEditorPreview(),
                  ),
                ),
              ],
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CodingQuestionCard(question: question),
                ),
                Container(
                  color: Colors.grey[850],
                  padding: const EdgeInsets.all(24),
                  child: const CodingEditorPreview(),
                ),
              ],
            ),
    );
  }
}
