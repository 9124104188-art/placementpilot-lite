// ignore_for_file: unused_catch_clause, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool loading = false;
  String? errorMsg;

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signIn(email.trim(), password.trim());
      // After login, you can navigate to home or just let auth state handle
    } on Exception catch (e) {
      setState(() => errorMsg = "Failed to login. Check your credentials.");
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
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 18),
          // Password
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (v) => password = v,
            validator: (v) =>
                (v == null || v.length < 6) ? 'Password too short' : null,
          ),
          const SizedBox(height: 16),
          if (errorMsg != null)
            Text(errorMsg!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: const Color.fromARGB(255, 0, 194, 255),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color.fromARGB(
                  255,
                  140,
                  222,
                  255,
                ),
                elevation: 4,
                shadowColor: const Color.fromARGB(80, 0, 194, 255),
              ),
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
