import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/create_status_screen.dart';
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

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  final firstLaunch = ref.watch(firstLaunchProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Wait for both async streams to resolve before deciding.
      if (auth.isLoading || firstLaunch.isLoading) return null;

      final loggedIn = auth.valueOrNull != null;
      final showOnboarding = firstLaunch.valueOrNull ?? false;

      final onAuthScreen = loc == '/login' || loc == '/register';
      final onOnboarding = loc == '/onboarding';

      // First-launch path: show onboarding once, before login.
      if (!loggedIn && showOnboarding && !onOnboarding && !onAuthScreen) {
        return '/onboarding';
      }

      // Standard auth gate.
      if (!loggedIn && !onAuthScreen && !onOnboarding) return '/login';
      if (loggedIn && (onAuthScreen || onOnboarding)) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
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
  }
  final Ref ref;
}
