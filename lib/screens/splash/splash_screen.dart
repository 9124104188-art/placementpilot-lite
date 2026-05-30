import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Simulate loading, then navigate to auth (you'll change this destination later)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xff6d60f6), Color(0xff32d2f9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Circle with gradient and icon
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 55,
                ),
              ),
            ).animate().scale(delay: 100.ms, duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 32),
            Text(
              "PlacementPilot Lite",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ).animate().fadeIn(delay: 300.ms, duration: 800.ms),

            const SizedBox(height: 16),
            Text(
              "Smart Placement Prep For College Students",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

            const SizedBox(height: 90),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              strokeWidth: 3,
            ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}