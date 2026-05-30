// ignore_for_file: unused_import, unused_catch_clause

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '', confirmPassword = '';
  bool loading = false;
  String? errorMsg;

  void signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.register(email.trim(), password.trim());
      // On registration, you can show a success message or auto-switch to login
    } on Exception catch (e) {
      setState(() => errorMsg = "Failed to sign up. Email might be in use.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => email = v,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
              if (!v.endsWith('@gmail.com')) return 'Email must be @gmail.com';
              return null;
            }
          ),
          const SizedBox(height: 14),
          // Password
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (v) => password = v,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            }
          ),
          const SizedBox(height: 14),
          // Confirm Password
          TextFormField(
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
            onChanged: (v) => confirmPassword = v,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != password) return 'Passwords don\'t match';
              return null;
            },
          ),
          const SizedBox(height: 12),
          if (errorMsg != null)
            Text(errorMsg!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : signup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: const Color(0xff32d2f9),
              ),
              child: loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Sign Up", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}