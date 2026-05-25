import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';
import 'widgets/env_badge.dart';

class FanPitchApp extends ConsumerWidget {
  const FanPitchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'FanPitch',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      // Overlay an env badge in non-prod builds so testers know which
      // backend they're hitting.
      builder: (ctx, child) => EnvBadge(child: child),
    );
  }
}
