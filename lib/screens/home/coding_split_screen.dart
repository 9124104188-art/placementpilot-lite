// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/coding_provider.dart';
import '../../widgets/coding_editor_preview.dart';

class CodingSplitScreen extends ConsumerStatefulWidget {
  const CodingSplitScreen({super.key});

  @override
  ConsumerState<CodingSplitScreen> createState() => _CodingSplitScreenState();
}

class _CodingSplitScreenState extends ConsumerState<CodingSplitScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(codingQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Coding — Split View')),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No coding questions yet'));
          }

          // clamp selection
          if (_selected >= questions.length) _selected = 0;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                // On narrow screens show list; tap -> full editor page
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: questions.length,
                  itemBuilder: (context, i) {
                    final q = questions[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(q.title),
                        subtitle: Text(q.difficulty),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _EditorPage(
                                questionIndex: i,
                                questions: questions,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }

              // Wide screens: two-column layout
              return Row(
                children: [
                  SizedBox(
                    width: 380,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: questions.length,
                      itemBuilder: (context, i) {
                        final q = questions[i];
                        return InkWell(
                          onTap: () => setState(() => _selected = i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selected == i
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                  : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  q.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  q.difficulty,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questions[_selected].title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: CodingEditorPreview(
                              initialInput: questions[_selected].sampleInput,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading questions: $e')),
      ),
    );
  }
}

class _EditorPage extends StatelessWidget {
  final int questionIndex;
  final List questions;

  const _EditorPage({
    required this.questionIndex,
    required this.questions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final q = questions[questionIndex];
    return Scaffold(
      appBar: AppBar(title: Text(q.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.description),
            const SizedBox(height: 12),
            Expanded(child: CodingEditorPreview(initialInput: q.sampleInput)),
          ],
        ),
      ),
    );
  }
}
