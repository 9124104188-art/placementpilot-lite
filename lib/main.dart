import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/coding_split_screen.dart';
import 'utils/themes/app_theme.dart'; // <- you’ll create this soon

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: PlacementPilotLiteApp()));
}

class PlacementPilotLiteApp extends ConsumerWidget {
  const PlacementPilotLiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'PlacementPilot Lite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/coding-split': (context) => const CodingSplitScreen(),
        // ...other routes
      },
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          } else {
            return const AuthScreen();
          }
        },
        loading: () => const SplashScreen(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
