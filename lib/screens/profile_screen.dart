import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final p = user.profile;
    final l = AppL10n.of(context);
    final locale = ref.watch(localeProvider);
    final currentCode =
        locale?.languageCode ?? Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 48,
                child: Text(
                  (p.displayName.isNotEmpty
                          ? p.displayName.substring(0, 1)
                          : user.username.substring(0, 1))
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                p.displayName.isEmpty ? user.username : p.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '@${user.username}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat(l.profilePoints, '${p.points}'),
                    _stat(l.profileLevel, '${p.level}'),
                    _stat(
                      l.profileCountry,
                      p.country?.isEmpty == false ? p.country! : '—',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(l.profileLanguage),
                subtitle: Text(
                  '${localeFlag(currentCode)}  ${localeDisplayName(currentCode)}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings/language'),
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(l.profileLogout),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      Text(label),
    ],
  );
}
