import 'package:flutter/material.dart';
import '../../models/coding_question.dart';
import '../../widgets/coding_editor_preview.dart';

class CodingEditorScreen extends StatelessWidget {
  final CodingQuestion question;

  const CodingEditorScreen({super.key, required this.question});

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(question.title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;

          final problemPane = _ProblemPane(
            question: question,
            difficultyColor: _difficultyColor(question.difficulty),
          );

          final editorPane = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Code Editor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: CodingEditorPreview(
                    question: question,
                    onAccepted: () async {
                      // show accepted banner briefly before asking confirmation
                      await Future.delayed(const Duration(milliseconds: 1500));

                      final shouldClose = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Submission Accepted'),
                          content: const Text(
                            'Your solution passed the test. Mark this question as completed and return to the list?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Stay'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Mark completed & Return'),
                            ),
                          ],
                        ),
                      );

                      if (shouldClose == true) Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 4, child: problemPane),
                const VerticalDivider(width: 1),
                Expanded(flex: 6, child: editorPane),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              problemPane,
              const SizedBox(height: 16),
              SizedBox(height: 560, child: editorPane),
            ],
          );
        },
      ),
    );
  }
}

class _ProblemPane extends StatelessWidget {
  final CodingQuestion question;
  final Color difficultyColor;

  const _ProblemPane({required this.question, required this.difficultyColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Row(
            children: [
              Chip(
                label: Text(question.difficulty),
                backgroundColor: difficultyColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: difficultyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${question.date.day}/${question.date.month}/${question.date.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Problem',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            question.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (question.sampleInput.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Sample Input',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            SelectableText(question.sampleInput),
          ],
          if (question.sampleOutput.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Sample Output',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            SelectableText(question.sampleOutput),
          ],
        ],
      ),
    );
  }
}
