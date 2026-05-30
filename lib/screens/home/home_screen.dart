// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'coding_page.dart';
import 'quiz_page.dart';
import 'notes_page.dart';
import 'progress_page.dart';
import '../quiz/quiz_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Dashboard(),
    CodingPage(),
    QuizHomeScreen(),
    NotesPage(),
    ProgressPage(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Coding Arena",
    "Aptitude Quiz",
    "Notes",
    "Progress",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              // Logout and let your auth state in main.dart redirect back to AuthScreen
              // Use Provider to sign out
              // E.g. context.read(authServiceProvider).signOut();
              // or with Riverpod:
              // ref.read(authServiceProvider).signOut();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: const Color(0xff6d60f6),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code_rounded),
            label: 'Coding',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes_rounded),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_rounded),
            label: 'Progress',
          ),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
