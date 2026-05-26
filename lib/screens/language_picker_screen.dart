import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../router.dart';
import '../theme.dart';

const _seenKey = 'fp_language_picker_seen_v1';

/// True if the first-launch language picker has not yet been confirmed.
///
/// We use a dedicated key (not the onboarding key) so that revisiting the
/// picker from Settings does not re-trigger the first-launch flow.
Future<bool> shouldShowLanguagePicker() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_seenKey) ?? false);
}

Future<void> markLanguagePickerSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_seenKey, true);
}

/// Shown once at first launch (before onboarding) and reachable later from
/// the profile settings via `/settings/language`.
class LanguagePickerScreen extends ConsumerStatefulWidget {
  const LanguagePickerScreen({super.key, this.fromSettings = false});

  /// `true` when reached from Settings — controls the post-save navigation
  /// (`Navigator.pop` instead of going to onboarding).
  final bool fromSettings;

  @override
  ConsumerState<LanguagePickerScreen> createState() =>
      _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends ConsumerState<LanguagePickerScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    // Pre-select the current locale if any — otherwise default to French
    // since that's our primary fan base.
    final current = ref.read(localeProvider);
    _selected = current?.languageCode ?? 'fr';
  }

  Future<void> _confirm() async {
    final code = _selected;
    if (code == null) return;
    await ref.read(localeProvider.notifier).set(Locale(code));
    await markLanguagePickerSeen();
    // Invalidate the gate so the router redirect no longer bounces us back
    // here. Without this, the FutureProvider keeps returning its cached
    // "language picker needed = true" value and the navigation looks frozen.
    ref.invalidate(languagePickerNeededProvider);
    if (!mounted) return;
    if (widget.fromSettings) {
      Navigator.of(context).pop();
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    // We may not have AppL10n yet on very first launch (locale not loaded),
    // but Flutter still gives us the device-language strings via the
    // delegates we wired in app.dart.
    final l = AppL10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? FanPitchColors.inkBlack : FanPitchColors.crowdWhite;
    final fg = isDark ? FanPitchColors.crowdWhite : FanPitchColors.inkBlack;

    return Scaffold(
      backgroundColor: bg,
      appBar: widget.fromSettings
          ? AppBar(
              backgroundColor: bg,
              elevation: 0,
              title: Text(l.profileLanguage),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.fromSettings)
                Row(
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
                  ],
                ),
              const SizedBox(height: 24),
              Text(
                l.languagePickerTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: fg,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.languagePickerSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: FanPitchColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: AppL10n.supportedLocales.map((l) {
                    final code = l.languageCode;
                    final selected = code == _selected;
                    return _LanguageTile(
                      flag: localeFlag(code),
                      name: localeDisplayName(code),
                      selected: selected,
                      onTap: () => setState(() => _selected = code),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: context.fp.brandGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _selected == null ? null : _confirm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            l.languagePickerContinue,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? FanPitchColors.pitchGreen.withValues(alpha: 0.12)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? FanPitchColors.pitchGreen
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: FanPitchColors.pitchGreen,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
