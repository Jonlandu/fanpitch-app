import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

/// Brand splash — shown while the auth bootstrap resolves.
/// Animated: logo scales+bounces in, ripples expand, wordmark fades up.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: context.fp.brandGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative ripples behind the logo
            ..._ripples(),

            // Logo + wordmark stacked
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/branding/logo_mark.svg',
                  width: 160,
                  height: 160,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                const Text(
                  'FanPitch',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: FanPitchColors.crowdWhite,
                    letterSpacing: -1.2,
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.4,
                      end: 0,
                      duration: 500.ms,
                      delay: 250.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(duration: 500.ms, delay: 250.ms),

                const SizedBox(height: 6),

                Text(
                  'REAL  ·  TIME  ·  FAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: FanPitchColors.crowdWhite.withValues(alpha: 0.85),
                    letterSpacing: 6,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
              ],
            ),

            // Loader at the very bottom
            Positioned(
              bottom: 64,
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(
                    FanPitchColors.crowdWhite.withValues(alpha: 0.7),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .fadeIn(duration: 400.ms, delay: 900.ms),
            ),
          ],
        ),
      ),
    );
  }

  // Three concentric expanding rings behind the logo
  List<Widget> _ripples() {
    return List.generate(3, (i) {
      return Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: FanPitchColors.crowdWhite.withValues(alpha: 0.18),
            width: 1.5,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(2.2, 2.2),
            duration: 2400.ms,
            delay: (i * 800).ms,
            curve: Curves.easeOut,
          )
          .fadeOut(duration: 2400.ms, delay: (i * 800).ms);
    });
  }
}
