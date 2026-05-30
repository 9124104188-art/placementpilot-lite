import 'package:flutter/material.dart';
// Navigation targets are disabled for now; imports removed to avoid warnings

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ListView(
        children: [
          // Welcome card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff6d60f6), Color(0xff32d2f9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '👋 Welcome!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'PlacementPilot Lite — a lightweight prep companion. Use the links below to jump to major sections.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'About this project',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'PlacementPilot Lite is an early preview that surfaces coding questions, quizzes, and study tools backed by Firestore. Notes, progress tracking, and many more updates are coming soon — stay tuned!',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Links card — separate elevated surface with disabled entries
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.surface,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.code_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text('Coding', style: theme.textTheme.titleMedium),
                      subtitle: Text(
                        'Solve coding challenges',
                        style: theme.textTheme.bodySmall,
                      ),
                      enabled: false,
                    ),
                    const Divider(height: 1),

                    ListTile(
                      leading: Icon(
                        Icons.quiz_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text('Quiz', style: theme.textTheme.titleMedium),
                      subtitle: Text(
                        'Timed quizzes & categories',
                        style: theme.textTheme.bodySmall,
                      ),
                      enabled: false,
                    ),
                    const Divider(height: 1),

                    ListTile(
                      leading: Icon(
                        Icons.notes_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text('Notes', style: theme.textTheme.titleMedium),
                      subtitle: Text(
                        'Save personal study notes',
                        style: theme.textTheme.bodySmall,
                      ),
                      enabled: false,
                    ),
                    const Divider(height: 1),

                    ListTile(
                      leading: Icon(
                        Icons.track_changes_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Progress',
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        'Track your learning progress',
                        style: theme.textTheme.bodySmall,
                      ),
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
