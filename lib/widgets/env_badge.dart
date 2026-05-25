import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/build_env.dart';

/// A small fixed ribbon in the top-right that signals which environment
/// (local / dev / staging) the app is talking to. Renders nothing in `prod`
/// so production builds look clean.
///
/// Wrap the whole app:
/// ```dart
/// MaterialApp.router(builder: (ctx, child) => EnvBadge(child: child));
/// ```
class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key, required this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final env = BuildEnv.current;
    if (!env.showBadge) return child ?? const SizedBox.shrink();

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child ?? const SizedBox.shrink(),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: _Ribbon(label: env.label, color: _colorFor(env)),
          ),
        ),
      ],
    );
  }

  static Color _colorFor(BuildEnv env) => switch (env) {
        BuildEnv.local   => FanPitchColors.muted,
        BuildEnv.dev     => FanPitchColors.fanOrange,
        BuildEnv.staging => FanPitchColors.gold,
        BuildEnv.prod    => Colors.transparent,
      };
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
