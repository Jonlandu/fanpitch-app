import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';

/// Persistent app locale, controlled from the language picker (onboarding
/// step 0) and from the profile settings.
///
/// The chosen language is stored under [_prefsKey] and survives reinstalls
/// only as long as shared_preferences does. If nothing is stored yet we
/// fall back to the device locale when it matches one we support, otherwise
/// to English.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null);

  static const _prefsKey = 'fp_locale_v1';

  /// Hydrate from shared_preferences. If no preference is stored yet, we
  /// keep [state] as `null` so MaterialApp falls back to the device locale
  /// (which Flutter then matches to one of our [supportedLocales]).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supportedCodes.contains(code)) {
      state = Locale(code);
    }
  }

  Future<void> set(Locale locale) async {
    if (!supportedCodes.contains(locale.languageCode)) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }

  /// Mirror of [AppL10n.supportedLocales] as a Set of language codes so we
  /// can validate stored values quickly.
  static final Set<String> supportedCodes = AppL10n.supportedLocales
      .map((l) => l.languageCode)
      .toSet();
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final n = LocaleNotifier();
  // Fire-and-forget hydration; UI rebuilds when state flips.
  n.load();
  return n;
});

/// User-facing name of a supported locale, in the locale's own language.
///
/// Falls back to the language code if unknown.
String localeDisplayName(String code) => switch (code) {
  'fr' => 'Français',
  'en' => 'English',
  'pt' => 'Português',
  'es' => 'Español',
  'de' => 'Deutsch',
  _ => code,
};

/// Emoji flag for the language picker chips.
String localeFlag(String code) => switch (code) {
  'fr' => '🇫🇷',
  'en' => '🇬🇧',
  'pt' => '🇵🇹',
  'es' => '🇪🇸',
  'de' => '🇩🇪',
  _ => '🏳️',
};
