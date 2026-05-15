import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(authProvider.notifier);
    final ok = await notifier.login(_username.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      context.go('/');
    } else {
      final err = notifier.lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_humanise(err))),
      );
    }
    if (mounted) setState(() => _busy = false);
  }

  String _humanise(Object? e) {
    final s = e?.toString() ?? 'Unknown error';
    if (s.contains('401')) return 'Wrong username or password.';
    if (s.contains('connection') || s.contains('XMLHttpRequest')) {
      return 'Cannot reach the server. Is daphne running?';
    }
    return 'Login failed: $s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text('FanPitch',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Live the match. Together. Out loud.',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 48),
              TextField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
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
                    : const Text('Log in'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
