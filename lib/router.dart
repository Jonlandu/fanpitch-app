import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/create_status_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tabs.dart';
import 'screens/match_room_screen.dart';
import 'screens/predictions_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // valueOrNull never throws, even when auth is in AsyncError (login failed).
      final loggedIn = auth.valueOrNull != null;
      final loggingIn = loc == '/login' || loc == '/register';
      if (auth.isLoading) return null;
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
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
        ],
      ),
    ],
  );
});
