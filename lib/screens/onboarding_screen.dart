import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

const _seenKey = 'fp_onboarding_seen_v1';

/// Returns true if the user has not yet completed the onboarding flow.
Future<bool> shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_seenKey) ?? false);
}

Future<void> _markSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_seenKey, true);
}

class _Page {
  final IconData icon;
  final Color iconColor;
  final String eyebrow;
  final String title;
  final String subtitle;
  const _Page({
    required this.icon,
    required this.iconColor,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
}

const _pages = <_Page>[
  _Page(
    icon: Icons.stadium_rounded,
    iconColor: FanPitchColors.pitchGreenHi,
    eyebrow: 'LIVE',
    title: 'Le match en direct\ndans ta poche.',
    subtitle:
        'Suis chaque but, carton et moment magique en temps réel — même quand tu n\'es pas devant la TV.',
  ),
  _Page(
    icon: Icons.local_fire_department_rounded,
    iconColor: FanPitchColors.fanOrange,
    eyebrow: 'TRIBE',
    title: 'Réagis avec\nta tribu.',
    subtitle:
        'Émojis qui fusent, sondages éclair, commentaires qui chauffent. Vis chaque action avec des milliers de fans.',
  ),
  _Page(
    icon: Icons.emoji_events_rounded,
    iconColor: FanPitchColors.gold,
    eyebrow: 'WIN',
    title: 'Prédis. Score.\nBrille.',
    subtitle:
        'Place tes paris avant le coup d\'envoi, gagne des points, débloque des badges et grimpe au classement.',
  ),
  _Page(
    icon: Icons.bolt_rounded,
    iconColor: FanPitchColors.pitchGreen,
    eyebrow: 'READY',
    title: 'Prêt à entrer\nsur le terrain ?',
    subtitle:
        'Rejoins la communauté FanPitch en 30 secondes. Aucune carte de crédit, juste ta passion.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await _markSeen();
    if (!mounted) return;
    context.go('/register');
  }

  Future<void> _skip() async {
    await _markSeen();
    if (!mounted) return;
    context.go('/login');
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? FanPitchColors.inkBlack : FanPitchColors.crowdWhite;
    final fg = isDark ? FanPitchColors.crowdWhite : FanPitchColors.inkBlack;
    final muted = FanPitchColors.muted;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header: brand mark + skip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/branding/logo_mark.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FanPitch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: fg,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  if (!_isLast)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Passer',
                        style: TextStyle(
                          color: muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Swipeable pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) =>
                    _PageView(page: _pages[i], isDark: isDark),
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final selected = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: selected
                          ? FanPitchColors.pitchGreen
                          : muted.withValues(alpha: 0.35),
                    ),
                  );
                }),
              ),
            ),

            // CTAs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: context.fp.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: FanPitchColors.pitchGreen.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _next,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                _isLast ? 'Créer mon compte' : 'Continuer',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: FanPitchColors.crowdWhite,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isLast) ...[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Déjà inscrit ? Connecte-toi',
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final _Page page;
  final bool isDark;
  const _PageView({required this.page, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? FanPitchColors.crowdWhite : FanPitchColors.inkBlack;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero — big circle with the page icon, brand-tinted, with floating particles
          Expanded(
            flex: 5,
            child: _HeroIllustration(icon: page.icon, color: page.iconColor)
                .animate(key: ValueKey(page.title))
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
          ),
          const SizedBox(height: 20),

          // Eyebrow chip
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: page.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  page.eyebrow,
                  style: TextStyle(
                    color: page.iconColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.6,
                  ),
                ),
              )
              .animate(key: ValueKey('${page.title}eyebrow'))
              .fadeIn(delay: 150.ms, duration: 350.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 150.ms,
                duration: 350.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 14),

          // Title
          Text(
                page.title,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: fg,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              )
              .animate(key: ValueKey('${page.title}title'))
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 200.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
                page.subtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: FanPitchColors.muted,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              )
              .animate(key: ValueKey('${page.title}sub'))
              .fadeIn(delay: 280.ms, duration: 400.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 280.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _HeroIllustration({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background blurred circle (brand gradient)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.30),
                  color.withValues(alpha: 0.05),
                  color.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Outer ring (animated rotation)
          Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.22),
                    width: 2,
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .rotate(
                duration: 12.seconds,
                begin: 0,
                end: 1,
                curve: Curves.linear,
              ),
          // Inner ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
          // Central solid disc
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Icon(icon, size: 64, color: Colors.white),
          ),
          // Decorative orbiting dots
          ...List.generate(4, (i) {
            final dx = 120 * (i.isEven ? 1.0 : -1.0);
            final dy = 110 * (i < 2 ? -1.0 : 1.0);
            return Transform.translate(
              offset: Offset(dx, dy),
              child:
                  Container(
                        width: i.isEven ? 14 : 10,
                        height: i.isEven ? 14 : 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i.isEven
                              ? FanPitchColors.fanOrange
                              : FanPitchColors.gold,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.1, 1.1),
                        duration: 1800.ms,
                        delay: (i * 200).ms,
                        curve: Curves.easeInOut,
                      ),
            );
          }),
        ],
      ),
    );
  }
}
