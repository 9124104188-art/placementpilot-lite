import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/quiz_providers.dart';
import '../../widgets/category_card.dart';
import 'quiz_play_screen.dart';

class QuizHomeScreen extends ConsumerWidget {
  const QuizHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(allQuizzesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quizzes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse quizzes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick a category, then jump straight into a focused round.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                quizzesAsync.when(
                  data: (quizList) => Row(
                    children: [
                      Expanded(
                        child: _statPill(
                          context,
                          label: 'Categories',
                          value: '${quizList.length}',
                          icon: Icons.grid_view_rounded,
                          color: const Color(0xff7dd3fc),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statPill(
                          context,
                          label: 'Rounds',
                          value: '15',
                          icon: Icons.timer_rounded,
                          color: const Color(0xff86efac),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statPill(
                          context,
                          label: 'Modes',
                          value: '3',
                          icon: Icons.tune_rounded,
                          color: const Color(0xffffb84d),
                        ),
                      ),
                    ],
                  ),
                  loading: () => _loadingRow(context),
                  error: (_, __) => Row(
                    children: [
                      Expanded(
                        child: _statPill(
                          context,
                          label: 'Categories',
                          value: '0',
                          icon: Icons.grid_view_rounded,
                          color: const Color(0xff7dd3fc),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statPill(
                          context,
                          label: 'Rounds',
                          value: '15',
                          icon: Icons.timer_rounded,
                          color: const Color(0xff86efac),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statPill(
                          context,
                          label: 'Modes',
                          value: '3',
                          icon: Icons.tune_rounded,
                          color: const Color(0xffffb84d),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Categories',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 146,
            child: quizzesAsync.when(
              data: (quizList) => quizList.isEmpty
                  ? _emptyCard(context)
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: quizList.length,
                      itemBuilder: (context, i) {
                        final quiz = quizList[i];
                        final category = quiz.category.trim();
                        final iconAsset = _iconAssetForCategory(category);
                        final categoryToOpen = category.isEmpty
                            ? quiz.title.trim()
                            : category;

                        return CategoryCard(
                          iconAsset: iconAsset,
                          categoryName: categoryToOpen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QuizPlayScreen(category: categoryToOpen),
                              ),
                            );
                          },
                        );
                      },
                    ),
              loading: () => _loadingCard(context),
              error: (e, _) => _errorCard(context, 'Failed to load categories'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingRow(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }

  Widget _loadingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _emptyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Center(
        child: Text(
          'No categories found yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _errorCard(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Center(
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

String _iconAssetForCategory(String category) {
  final normalized = category.toLowerCase().replaceAll(' ', '');

  if (normalized.isEmpty || normalized.contains('python')) {
    return 'assets/icons/python.svg';
  }

  return 'assets/icons/python.svg';
}
