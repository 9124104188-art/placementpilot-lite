import 'package:flutter/material.dart';
import 'login_form.dart';
import 'signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF19202A) : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.school_rounded, size: 50, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                "PlacementPilot Lite",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              // Tabs for Login/Signup
              Container(
                decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20)),
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Login"),
                    Tab(text: "Sign Up"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    LoginForm(),
                    SignupForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}