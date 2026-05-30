// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/coding_question.dart';
import '../../providers/coding_provider.dart';
import '../../widgets/coding_question_card.dart';
import 'coding_editor_screen.dart';

class CodingPage extends ConsumerStatefulWidget {
  const CodingPage({super.key});

  @override
  ConsumerState<CodingPage> createState() => _CodingPageState();
}

class _CodingPageState extends ConsumerState<CodingPage> {
  static const List<String> _difficultyFilters = [
    'All',
    'Easy',
    'Medium',
    'Hard',
  ];

  String _selectedDifficultyFilter = 'All';
  final Set<String> _completedQuestionIds = <String>{};

  void _setFilter(String filter) {
    setState(() {
      _selectedDifficultyFilter = filter;
    });
  }

  void _toggleCompleted(String questionId) {
    setState(() {
      if (_completedQuestionIds.contains(questionId)) {
        _completedQuestionIds.remove(questionId);
      } else {
        _completedQuestionIds.add(questionId);
      }
    });
  }

  bool _matchesFilter(CodingQuestion question) {
    return _selectedDifficultyFilter == 'All' ||
        question.difficulty == _selectedDifficultyFilter;
  }

  @override
  Widget build(BuildContext context) {
    final codingQuestionsAsync = ref.watch(codingQuestionsProvider);
    final dailyQuestionAsync = ref.watch(dailyQuestionProvider);
    final userStatsAsync = ref.watch(userStatsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        const SizedBox(height: 8),
        dailyQuestionAsync.when(
          data: (question) => question == null
              ? const SizedBox.shrink()
              : _dailyQuestionCard(context, question),
          loading: () => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: LinearProgressIndicator(minHeight: 3),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Difficulty',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _difficultyFilters
              .map(
                (filter) => ChoiceChip(
                  label: Text(filter),
                  selected: _selectedDifficultyFilter == filter,
                  onSelected: (_) => _setFilter(filter),
                  selectedColor: const Color(
                    0xff2563eb,
                  ).withValues(alpha: 0.14),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Text(
          'Arena',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        codingQuestionsAsync.when(
          data: (questions) {
            final visibleQuestions = questions.where(_matchesFilter).toList();

            if (questions.isEmpty) {
              return _emptyStateCard(
                context,
                title: 'No coding questions yet',
                message:
                    'Once questions are published, they will appear here with progress and XP context.',
              );
            }

            if (visibleQuestions.isEmpty) {
              return _emptyStateCard(
                context,
                title: 'No matches for this filter',
                message:
                    'Switch to another difficulty or clear the filter to see the full feed.',
                actionLabel: 'Show all',
                onAction: () => _setFilter('All'),
              );
            }

            return Column(
              children: [
                for (final question in visibleQuestions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CodingQuestionCard(
                      question: question,
                      isCompleted: _completedQuestionIds.contains(question.id),
                      onToggleCompleted: () => _toggleCompleted(question.id),
                      onTap: () async {
                        final completed = await Navigator.of(context)
                            .push<bool?>(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CodingEditorScreen(question: question),
                              ),
                            );

                        if (completed == true) {
                          _toggleCompleted(question.id);
                        }
                      },
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading: $e')),
        ),
      ],
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

  Widget _loadingPill(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
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

  Widget _progressPanel(
    BuildContext context, {
    required double progress,
    required int streak,
    required int xp,
  }) {
    final progressPercent = (progress.clamp(0, 1) * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xff22c55e),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Your momentum',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '$xp XP',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.clamp(0, 1),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniBadge(
                context,
                icon: Icons.local_fire_department_rounded,
                label: '$streak day streak',
                color: const Color(0xffff7a00),
              ),
              const SizedBox(width: 10),
              _miniBadge(
                context,
                icon: Icons.emoji_events_rounded,
                label: '$progressPercent% complete',
                color: const Color(0xff2563eb),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _accentPill(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _loadingPanel() {
    return Container(
      height: 146,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _miniBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyQuestionCard(BuildContext context, CodingQuestion question) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xfff8fafc), Color(0xffeff6ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffbfdbfe)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff2563eb).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Today\'s pick',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xff2563eb),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Chip(label: Text(question.difficulty)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            question.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _emptyStateCard(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.code_off_rounded, size: 42, color: Colors.grey[500]),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}
