// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

import '../models/coding_question.dart';

class CodingQuestionCard extends StatefulWidget {
  final CodingQuestion question;
  final VoidCallback? onTap;
  final bool isCompleted;
  final VoidCallback? onToggleCompleted;

  const CodingQuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.isCompleted = false,
    this.onToggleCompleted,
  });

  @override
  State<CodingQuestionCard> createState() => _CodingQuestionCardState();
}

class _CodingQuestionCardState extends State<CodingQuestionCard> {
  bool isExpanded = false;

  Color getDifficultyColor(String difficulty) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final difficultyColor = getDifficultyColor(widget.question.difficulty);
    const completedColor = Color(0xff16a34a);
    // Keep the card accent based on difficulty; use a separate pill to show completed state
    final accentColor = difficultyColor;
    final cardSurface = colorScheme.surfaceContainerLow;
    final titleColor = colorScheme.onSurface;
    final bodyColor = colorScheme.onSurfaceVariant;
    final subtleBorder = colorScheme.outlineVariant.withValues(alpha: 0.8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
            return;
          }

          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.22),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    widget.question.difficulty,
                                    style: TextStyle(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (widget.isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                if (widget.isCompleted)
                                  const SizedBox(width: 8),
                                Text(
                                  'Coding challenge',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: bodyColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.question.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: bodyColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.question.description,
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.35,
                      color: bodyColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _metaChip(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label:
                            '${widget.question.date.day}/${widget.question.date.month}/${widget.question.date.year}',
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _metaChip(
                        context,
                        icon: Icons.touch_app_rounded,
                        label: widget.onTap != null ? 'Open' : 'Expand',
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 14),
                    Divider(height: 1, color: subtleBorder),
                    const SizedBox(height: 14),
                    if (widget.question.sampleInput.isNotEmpty)
                      _sampleBlock(
                        context,
                        title: 'Sample Input',
                        value: widget.question.sampleInput,
                        accent: colorScheme.primary,
                      ),
                    if (widget.question.sampleOutput.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _sampleBlock(
                        context,
                        title: 'Sample Output',
                        value: widget.question.sampleOutput,
                        accent: colorScheme.tertiary,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Show solution or open discussion
                            },
                            icon: const Icon(Icons.visibility_rounded),
                            label: const Text('Show Solution'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onToggleCompleted,
                            icon: Icon(
                              widget.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                            ),
                            label: Text(
                              widget.isCompleted ? 'Completed' : 'Mark Done',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              disabledBackgroundColor: colorScheme.secondary
                                  .withValues(alpha: 0.55),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sampleBlock(
    BuildContext context, {
    required String title,
    required String value,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
