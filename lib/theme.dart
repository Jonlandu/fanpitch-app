// ─────────────────────────────────────────────────────────────────────
// FanPitch Theme System
// ─────────────────────────────────────────────────────────────────────
// Brand palette (locked):
//   Pitch Green  #00A651   — primary, CTAs, brand
//   Pitch Green+ #1FB76C   — primary hover / lighter shade
//   Fan Orange   #FF6B2C   — accent, energy moments, live state
//   Fan Orange+  #FF8852   — orange hover
//   Ink Black    #0D1117   — text on light, dark backgrounds
//   Soft Ink     #1B2027   — secondary surfaces on dark
//   Crowd White  #FFFFFF   — primary surface on light
//   Off White    #F5F7F8   — secondary surface on light
//
// Use `Theme.of(context).extension<FanPitchPalette>()!` to access brand
// gradients and semantic colors (live, badge gold, etc.) that don't fit in
// the standard Material 3 ColorScheme.
// ─────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

// ── Brand palette as plain constants ─────────────────────────────────
class FanPitchColors {
  static const pitchGreen = Color(0xFF00A651);
  static const pitchGreenHi = Color(0xFF1FB76C);
  static const pitchGreenLo = Color(0xFF007A3D);

  static const fanOrange = Color(0xFFFF6B2C);
  static const fanOrangeHi = Color(0xFFFF8852);
  static const fanOrangeLo = Color(0xFFE65420);

  static const inkBlack = Color(0xFF0D1117);
  static const softInk = Color(0xFF1B2027);
  static const slate = Color(0xFF3A4452);

  static const crowdWhite = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF5F7F8);
  static const muted = Color(0xFFA3ACB7);

  // Semantic
  static const live = Color(0xFFE5363B); // live match dot
  static const gold = Color(0xFFFFC83D); // top badges, MOTM
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
}

// ── Custom theme extension for the brand-specific palette ────────────
@immutable
class FanPitchPalette extends ThemeExtension<FanPitchPalette> {
  final Color liveIndicator;
  final Color goldBadge;
  final Color success;
  final Color danger;
  final Gradient brandGradient;
  final Gradient liveGradient;
  final Gradient surfaceGradient;
  final Color reactionFire;
  final Color reactionLaugh;

  const FanPitchPalette({
    required this.liveIndicator,
    required this.goldBadge,
    required this.success,
    required this.danger,
    required this.brandGradient,
    required this.liveGradient,
    required this.surfaceGradient,
    required this.reactionFire,
    required this.reactionLaugh,
  });

  @override
  FanPitchPalette copyWith({
    Color? liveIndicator,
    Color? goldBadge,
    Color? success,
    Color? danger,
    Gradient? brandGradient,
    Gradient? liveGradient,
    Gradient? surfaceGradient,
    Color? reactionFire,
    Color? reactionLaugh,
  }) => FanPitchPalette(
    liveIndicator: liveIndicator ?? this.liveIndicator,
    goldBadge: goldBadge ?? this.goldBadge,
    success: success ?? this.success,
    danger: danger ?? this.danger,
    brandGradient: brandGradient ?? this.brandGradient,
    liveGradient: liveGradient ?? this.liveGradient,
    surfaceGradient: surfaceGradient ?? this.surfaceGradient,
    reactionFire: reactionFire ?? this.reactionFire,
    reactionLaugh: reactionLaugh ?? this.reactionLaugh,
  );

  @override
  FanPitchPalette lerp(ThemeExtension<FanPitchPalette>? other, double t) {
    if (other is! FanPitchPalette) return this;
    return FanPitchPalette(
      liveIndicator: Color.lerp(liveIndicator, other.liveIndicator, t)!,
      goldBadge: Color.lerp(goldBadge, other.goldBadge, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      brandGradient: t < 0.5 ? brandGradient : other.brandGradient,
      liveGradient: t < 0.5 ? liveGradient : other.liveGradient,
      surfaceGradient: t < 0.5 ? surfaceGradient : other.surfaceGradient,
      reactionFire: Color.lerp(reactionFire, other.reactionFire, t)!,
      reactionLaugh: Color.lerp(reactionLaugh, other.reactionLaugh, t)!,
    );
  }
}

// ── Shared text theme (sizes only — color comes from ColorScheme) ────
TextTheme _buildTextTheme(Color base) => TextTheme(
  displayLarge: TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    color: base,
    height: 1.05,
  ),
  displayMedium: TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: base,
    height: 1.10,
  ),
  displaySmall: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: base,
    height: 1.15,
  ),
  headlineLarge: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: base,
    height: 1.20,
  ),
  headlineMedium: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: base,
    height: 1.25,
  ),
  headlineSmall: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: base,
    height: 1.30,
  ),
  titleLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: base,
    height: 1.35,
  ),
  titleMedium: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: base,
    height: 1.40,
  ),
  titleSmall: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: base,
    height: 1.40,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: base,
    height: 1.50,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: base,
    height: 1.50,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: base,
    height: 1.50,
  ),
  labelLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: base,
  ),
  labelMedium: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: base,
  ),
  labelSmall: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: base,
  ),
);

// ── Light theme ──────────────────────────────────────────────────────
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: FanPitchColors.crowdWhite,
  colorScheme: const ColorScheme.light(
    primary: FanPitchColors.pitchGreen,
    onPrimary: FanPitchColors.crowdWhite,
    primaryContainer: Color(0xFFCCEFD9),
    onPrimaryContainer: FanPitchColors.pitchGreenLo,
    secondary: FanPitchColors.fanOrange,
    onSecondary: FanPitchColors.crowdWhite,
    secondaryContainer: Color(0xFFFFD9C5),
    onSecondaryContainer: FanPitchColors.fanOrangeLo,
    tertiary: FanPitchColors.gold,
    onTertiary: FanPitchColors.inkBlack,
    error: FanPitchColors.danger,
    onError: FanPitchColors.crowdWhite,
    surface: FanPitchColors.crowdWhite,
    onSurface: FanPitchColors.inkBlack,
    surfaceContainer: FanPitchColors.offWhite,
    surfaceContainerHigh: Color(0xFFEEF1F3),
    outline: Color(0xFFD8DEE3),
    outlineVariant: Color(0xFFE9EDEF),
  ),
  textTheme: _buildTextTheme(FanPitchColors.inkBlack),
  fontFamily: null, // platform default (SF on iOS, Roboto on Android)
  splashFactory: InkRipple.splashFactory,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0.6,
    centerTitle: false,
    backgroundColor: FanPitchColors.crowdWhite,
    foregroundColor: FanPitchColors.inkBlack,
    titleTextStyle: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: FanPitchColors.inkBlack,
      letterSpacing: -0.3,
    ),
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: FanPitchColors.crowdWhite,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFE9EDEF), width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: FanPitchColors.pitchGreen,
      foregroundColor: FanPitchColors.crowdWhite,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      minimumSize: const Size(0, 48),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: FanPitchColors.fanOrange,
      foregroundColor: FanPitchColors.crowdWhite,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: FanPitchColors.inkBlack,
      side: const BorderSide(color: Color(0xFFD8DEE3), width: 1.4),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: FanPitchColors.pitchGreen,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: FanPitchColors.offWhite,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE9EDEF), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: FanPitchColors.pitchGreen,
        width: 1.8,
      ),
    ),
    hintStyle: const TextStyle(color: FanPitchColors.muted, fontSize: 14),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: FanPitchColors.offWhite,
    selectedColor: FanPitchColors.pitchGreen.withValues(alpha: 0.12),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: FanPitchColors.inkBlack,
    ),
    side: const BorderSide(color: Color(0xFFE9EDEF)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: FanPitchColors.crowdWhite,
    selectedItemColor: FanPitchColors.pitchGreen,
    unselectedItemColor: FanPitchColors.muted,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: FanPitchColors.crowdWhite,
    indicatorColor: FanPitchColors.pitchGreen.withValues(alpha: 0.14),
    height: 64,
    elevation: 6,
    surfaceTintColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 11,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w500,
        color: states.contains(WidgetState.selected)
            ? FanPitchColors.pitchGreen
            : FanPitchColors.muted,
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? FanPitchColors.pitchGreen
            : FanPitchColors.muted,
        size: 24,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE9EDEF),
    thickness: 1,
    space: 0,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: FanPitchColors.inkBlack,
    contentTextStyle: TextStyle(
      color: FanPitchColors.crowdWhite,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  ),
  extensions: const [
    FanPitchPalette(
      liveIndicator: FanPitchColors.live,
      goldBadge: FanPitchColors.gold,
      success: FanPitchColors.success,
      danger: FanPitchColors.danger,
      brandGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [FanPitchColors.pitchGreen, FanPitchColors.fanOrange],
      ),
      liveGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [FanPitchColors.live, FanPitchColors.fanOrange],
      ),
      surfaceGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [FanPitchColors.crowdWhite, FanPitchColors.offWhite],
      ),
      reactionFire: FanPitchColors.fanOrange,
      reactionLaugh: FanPitchColors.gold,
    ),
  ],
);

// ── Dark theme ───────────────────────────────────────────────────────
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: FanPitchColors.inkBlack,
  colorScheme: const ColorScheme.dark(
    primary: FanPitchColors.pitchGreenHi,
    onPrimary: FanPitchColors.inkBlack,
    primaryContainer: Color(0xFF0E5C2F),
    onPrimaryContainer: Color(0xFFCCEFD9),
    secondary: FanPitchColors.fanOrangeHi,
    onSecondary: FanPitchColors.inkBlack,
    secondaryContainer: Color(0xFF7A2E12),
    onSecondaryContainer: Color(0xFFFFD9C5),
    tertiary: FanPitchColors.gold,
    onTertiary: FanPitchColors.inkBlack,
    error: FanPitchColors.danger,
    onError: FanPitchColors.crowdWhite,
    surface: FanPitchColors.inkBlack,
    onSurface: FanPitchColors.crowdWhite,
    surfaceContainer: FanPitchColors.softInk,
    surfaceContainerHigh: Color(0xFF252B33),
    outline: Color(0xFF2D3540),
    outlineVariant: Color(0xFF222831),
  ),
  textTheme: _buildTextTheme(FanPitchColors.crowdWhite),
  fontFamily: null,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0.6,
    centerTitle: false,
    backgroundColor: FanPitchColors.inkBlack,
    foregroundColor: FanPitchColors.crowdWhite,
    titleTextStyle: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: FanPitchColors.crowdWhite,
      letterSpacing: -0.3,
    ),
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: FanPitchColors.softInk,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFF222831), width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: FanPitchColors.pitchGreenHi,
      foregroundColor: FanPitchColors.inkBlack,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      minimumSize: const Size(0, 48),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: FanPitchColors.softInk,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2D3540), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: FanPitchColors.pitchGreenHi,
        width: 1.8,
      ),
    ),
    hintStyle: const TextStyle(color: FanPitchColors.muted, fontSize: 14),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: FanPitchColors.softInk,
    selectedColor: FanPitchColors.pitchGreen.withValues(alpha: 0.20),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: FanPitchColors.crowdWhite,
    ),
    side: const BorderSide(color: Color(0xFF2D3540)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: FanPitchColors.inkBlack,
    indicatorColor: FanPitchColors.pitchGreen.withValues(alpha: 0.22),
    height: 64,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 11,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w500,
        color: states.contains(WidgetState.selected)
            ? FanPitchColors.pitchGreenHi
            : FanPitchColors.muted,
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? FanPitchColors.pitchGreenHi
            : FanPitchColors.muted,
        size: 24,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF222831),
    thickness: 1,
    space: 0,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: FanPitchColors.crowdWhite,
    contentTextStyle: TextStyle(
      color: FanPitchColors.inkBlack,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  ),
  extensions: const [
    FanPitchPalette(
      liveIndicator: FanPitchColors.live,
      goldBadge: FanPitchColors.gold,
      success: FanPitchColors.success,
      danger: FanPitchColors.danger,
      brandGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [FanPitchColors.pitchGreen, FanPitchColors.fanOrange],
      ),
      liveGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [FanPitchColors.live, FanPitchColors.fanOrange],
      ),
      surfaceGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [FanPitchColors.inkBlack, FanPitchColors.softInk],
      ),
      reactionFire: FanPitchColors.fanOrange,
      reactionLaugh: FanPitchColors.gold,
    ),
  ],
);

// ── Convenience accessor ─────────────────────────────────────────────
extension FanPitchThemeX on BuildContext {
  FanPitchPalette get fp => Theme.of(this).extension<FanPitchPalette>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get type => Theme.of(this).textTheme;
}
