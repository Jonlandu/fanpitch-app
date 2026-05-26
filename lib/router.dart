import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/create_status_screen.dart';
import 'screens/language_picker_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tabs.dart';
import 'screens/match_room_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/predictions_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_profile_screen.dart';

/// True until the user has tapped through the onboarding flow once.
final firstLaunchProvider = FutureProvider<bool>((ref) async {
  return shouldShowOnboarding();
});

/// True until the user has confirmed a language at first launch.
final languagePickerNeededProvider = FutureProvider<bool>((ref) async {
  return shouldShowLanguagePicker();
});

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  final firstLaunch = ref.watch(firstLaunchProvider);
  final langNeeded = ref.watch(languagePickerNeededProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Wait for every async stream to resolve before deciding.
      if (auth.isLoading || firstLaunch.isLoading || langNeeded.isLoading) {
        return null;
      }

      final loggedIn = auth.valueOrNull != null;
      final showOnboarding = firstLaunch.valueOrNull ?? false;
      final showLanguage = langNeeded.valueOrNull ?? false;

      final onAuthScreen = loc == '/login' || loc == '/register';
      final onOnboarding = loc == '/onboarding';
      final onLanguage = loc == '/language';
      // Settings-reached language picker — never redirects.
      final onSettingsLanguage = loc == '/settings/language';

      // First-launch language picker takes priority over everything else.
      if (!loggedIn && showLanguage && !onLanguage && !onSettingsLanguage) {
        return '/language';
      }

      // First-launch onboarding path.
      if (!loggedIn &&
          !showLanguage &&
          showOnboarding &&
          !onOnboarding &&
          !onAuthScreen) {
        return '/onboarding';
      }

      // Standard auth gate (settings/language stays reachable while logged in).
      if (!loggedIn &&
          !onAuthScreen &&
          !onOnboarding &&
          !onLanguage &&
          !onSettingsLanguage) {
        return '/login';
      }
      if (loggedIn && (onAuthScreen || onOnboarding || onLanguage)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/language',
        builder: (_, __) => const LanguagePickerScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (_, __) => const LanguagePickerScreen(fromSettings: true),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/',
        builder: (_, __) => const MainTabs(),
        routes: [
          GoRoute(
            path: 'match/:id',
            builder: (ctx, st) =>
                MatchRoomScreen(matchId: int.parse(st.pathParameters['id']!)),
          ),
          GoRoute(
            path: 'status/new',
            builder: (_, __) => const CreateStatusScreen(),
          ),
          GoRoute(
            path: 'predict/:id',
            builder: (ctx, st) =>
                PredictionsScreen(matchId: int.parse(st.pathParameters['id']!)),
          ),
          GoRoute(
            path: 'leaderboard',
            builder: (_, __) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: 'u/:id',
            builder: (ctx, st) =>
                UserProfileScreen(userId: int.parse(st.pathParameters['id']!)),
          ),
        ],
      ),
    ],
  );
});

/// Bridges Riverpod state changes to go_router's Listenable contract,
/// so the redirect re-runs whenever auth or onboarding state flips.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(firstLaunchProvider, (_, __) => notifyListeners());
    ref.listen(languagePickerNeededProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

// kDebugMode kept to silence the unused-import warning Dart 3 might raise
// after editing this file repeatedly.
// ignore: unused_element
const _kDebug = kDebugMode;
