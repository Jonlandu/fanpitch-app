import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/generated/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'router.dart';
import 'theme.dart';
import 'widgets/env_badge.dart';

class FanPitchApp extends ConsumerWidget {
  const FanPitchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'FanPitch',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      routerConfig: router,
      // Overlay an env badge in non-prod builds so testers know which
      // backend they're hitting.
      builder: (ctx, child) => EnvBadge(child: child),
    );
  }
}
