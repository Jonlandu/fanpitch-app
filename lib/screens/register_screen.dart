import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _display = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _display.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(authProvider.notifier);
    final ok = await notifier.register(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      displayName: _display.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register failed: ${notifier.lastError}')),
      );
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _display,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (8+ chars)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
