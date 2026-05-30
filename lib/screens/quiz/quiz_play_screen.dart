// ignore_for_file: prefer_const_constructors, deprecated_member_use, unused_local_variable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quiz_providers.dart';
import '../../models/question.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final String category;

  const QuizPlayScreen({super.key, required this.category});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  int? selectedDifficulty;
  int roundNonce = 0;
  bool roundCompleted = false;
  List<_QuestionResult> roundResults = const [];
  int roundScore = 0;

  void _startRound(int difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      roundCompleted = false;
      roundResults = const [];
      roundScore = 0;
      roundNonce++;
    });
  }

  void _retakeRound() {
    if (selectedDifficulty == null) return;

    setState(() {
      roundCompleted = false;
      roundNonce++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = selectedDifficulty == null
        ? null
        : ref.watch(
            questionsByCategoryAndDifficultyProvider((
              category: widget.category,
              difficulty: selectedDifficulty!,
              nonce: roundNonce,
            )),
          );

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: roundCompleted
            ? _RoundCompleteView(
                scoreText: '$roundScore / ${roundResults.length}',
                results: roundResults,
                onRetake: _retakeRound,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Difficulty level',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _DifficultyCard(
                                label: 'Easy',
                                description: 'Warm up round',
                                icon: Icons.bolt_rounded,
                                isSelected: selectedDifficulty == 1,
                                onTap: () => _startRound(1),
                              ),
                              _DifficultyCard(
                                label: 'Medium',
                                description: 'Balanced challenge',
                                icon: Icons.trending_up_rounded,
                                isSelected: selectedDifficulty == 2,
                                onTap: () => _startRound(2),
                              ),
                              _DifficultyCard(
                                label: 'Hard',
                                description: 'Advanced mode',
                                icon: Icons.local_fire_department_rounded,
                                isSelected: selectedDifficulty == 3,
                                onTap: () => _startRound(3),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Only the first 15 questions for the selected difficulty will be shown.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: selectedDifficulty == null
                        ? const _DifficultyPrompt()
                        : questionsAsync!.when(
                            data: (questions) => questions.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No questions yet for this difficulty.',
                                    ),
                                  )
                                : _QuestionPager(
                                    questions: questions,
                                    onFinished: (score, results) {
                                      setState(() {
                                        roundCompleted = true;
                                        roundScore = score;
                                        roundResults = results;
                                      });
                                    },
                                  ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Center(child: Text('Error: $e')),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = isSelected ? colorScheme.primary : colorScheme.outline;
    final backgroundColor = isSelected
        ? colorScheme.primaryContainer.withValues(alpha: 0.98)
        : colorScheme.surfaceContainerLowest;
    final titleColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final descriptionColor = isSelected
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 165,
      height: 128,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.28)
                  : colorScheme.outlineVariant.withValues(alpha: 0.75),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.14)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.1,
                  color: descriptionColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundCompleteView extends StatelessWidget {
  final String scoreText;
  final List<_QuestionResult> results;
  final VoidCallback onRetake;

  const _RoundCompleteView({
    required this.scoreText,
    required this.results,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffeff6ff), Color(0xfff8fafc)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 34,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quiz Complete!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: $scoreText',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _EndAnswersPanel(results: results),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onRetake,
            child: const Text('Retake Same Difficulty'),
          ),
        ),
      ],
    );
  }
}

class _DifficultyPrompt extends StatelessWidget {
  const _DifficultyPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 54, color: Colors.grey.shade600),
          const SizedBox(height: 12),
          const Text(
            'Choose a difficulty to start the quiz.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QuestionPager extends StatefulWidget {
  final List<Question> questions;
  final void Function(int score, List<_QuestionResult> results) onFinished;

  const _QuestionPager({required this.questions, required this.onFinished});

  @override
  State<_QuestionPager> createState() => _QuestionPagerState();
}

class _QuestionPagerState extends State<_QuestionPager> {
  late List<List<String>> shuffledOptions;
  late List<String?> selected;
  int idx = 0;

  @override
  void initState() {
    super.initState();
    selected = List<String?>.filled(widget.questions.length, null);
    shuffledOptions = widget.questions
        .map((question) => [...question.options]..shuffle(Random()))
        .toList();
  }

  void handleSubmit() {
    int total = 0;
    final results = <_QuestionResult>[];
    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final sel = selected[i];
      if (sel != null && sel == q.correctAnswer) total++;
      results.add(_QuestionResult(question: q, selectedAnswer: sel));
    }

    widget.onFinished(total, results);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final q = widget.questions[idx];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${idx + 1} of ${widget.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                q.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              ...shuffledOptions[idx].map((opt) {
                final isSelected = selected[idx] == opt;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer.withOpacity(0.78)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: isSelected ? 1.4 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : null,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                    leading: Radio<String>(
                      value: opt,
                      groupValue: selected[idx],
                      activeColor: colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          selected[idx] = val;
                        });
                      },
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        selected[idx] = opt;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (idx > 0)
                    ElevatedButton(
                      onPressed: () => setState(() => idx--),
                      child: const Text('Previous'),
                    ),
                  if (idx < widget.questions.length - 1)
                    ElevatedButton(
                      onPressed: selected[idx] == null
                          ? null
                          : () => setState(() => idx++),
                      child: const Text('Next'),
                    ),
                  if (idx == widget.questions.length - 1)
                    ElevatedButton(
                      onPressed: selected[idx] == null ? null : handleSubmit,
                      child: const Text('Submit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionResult {
  final Question question;
  final String? selectedAnswer;

  const _QuestionResult({required this.question, required this.selectedAnswer});
}

class _EndAnswersPanel extends StatefulWidget {
  final List<_QuestionResult> results;

  const _EndAnswersPanel({required this.results});

  @override
  State<_EndAnswersPanel> createState() => _EndAnswersPanelState();
}

class _EndAnswersPanelState extends State<_EndAnswersPanel> {
  bool showAnswers = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  showAnswers = !showAnswers;
                });
              },
              icon: Icon(showAnswers ? Icons.visibility_off : Icons.visibility),
              label: Text(showAnswers ? 'Hide Answers' : 'Show Answers'),
            ),
            if (showAnswers) ...[
              const SizedBox(height: 8),
              ...widget.results.map((result) {
                final isCorrect =
                    result.selectedAnswer == result.question.correctAnswer;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.question.question,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your answer: ${result.selectedAnswer ?? "Not answered"}',
                      ),
                      Text(
                        'Correct answer: ${result.question.correctAnswer}',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 18),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
