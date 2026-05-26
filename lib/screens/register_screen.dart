import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
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
  String? _country;
  bool _busy = false;

  /// Countries that match the teams we seed on prod, so a new fan can
  /// pick the same flag as one of the demo squads. Flag + label + value
  /// keep us decoupled from any backend-side list.
  static const _countries = <({String flag, String value, String label})>[
    (flag: '🇨🇩', value: 'DR Congo', label: 'DR Congo'),
    (flag: '🇵🇹', value: 'Portugal', label: 'Portugal'),
    (flag: '🇫🇷', value: 'France', label: 'France'),
    (flag: '🇦🇷', value: 'Argentina', label: 'Argentina'),
    (flag: '🇧🇷', value: 'Brazil', label: 'Brazil'),
    (flag: '🇲🇦', value: 'Morocco', label: 'Morocco'),
    (flag: '🇸🇳', value: 'Senegal', label: 'Senegal'),
    (flag: '🇨🇲', value: 'Cameroon', label: 'Cameroon'),
    (flag: '🇪🇸', value: 'Spain', label: 'Spain'),
    (flag: '🇳🇬', value: 'Nigeria', label: 'Nigeria'),
  ];

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
      country: _country,
    );
    if (!mounted) return;
    if (ok) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppL10n.of(
              context,
            ).registerFailed(notifier.lastError?.toString() ?? '—'),
          ),
        ),
      );
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.registerTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _display,
                decoration: InputDecoration(
                  labelText: l.registerDisplayName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: l.registerUsername,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l.registerEmail,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l.registerPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _country,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l.registerCountry,
                  border: const OutlineInputBorder(),
                ),
                hint: Text(l.registerCountryHint),
                items: _countries
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.value,
                        child: Row(
                          children: [
                            Text(c.flag, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Text(c.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _country = v),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.registerSubmit),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : () => context.go('/login'),
                child: Text(l.registerHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
