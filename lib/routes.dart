import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/auth/models/user.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/auth/screens/login_screen.dart';
import 'package:watch2earn/features/auth/screens/register_screen.dart';
import 'package:watch2earn/features/favorites/screens/favorites_screen.dart';
import 'package:watch2earn/features/home/screens/home_screen.dart';
import 'package:watch2earn/features/main_screen.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/movies/screens/movie_detail_screen.dart';
import 'package:watch2earn/features/profile/screens/profile_screen.dart';
import 'package:watch2earn/features/rewards/screens/rewards_screen.dart';
import 'package:watch2earn/features/search/screens/search_screen.dart';
import 'package:watch2earn/features/settings/screens/settings_screen.dart';
import 'package:watch2earn/features/splash_screen.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';
import 'package:watch2earn/features/tv_shows/screens/tv_show_detail_screen.dart';
import 'package:watch2earn/features/tv_shows/screens/tv_show_season_screen.dart';
import 'package:watch2earn/features/watchlist/screens/watchlist_screen.dart';

// Helper class for GoRouter to listen to auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Notify initially to start with proper state

    _subscription = stream.asBroadcastStream().listen(
          (_) {
        developer.log('Auth state changed, refreshing router', name: 'GoRouterRefresh');
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Provider for the GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authControllerProvider.notifier);
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      developer.log(
          'Router redirect: path=${state.location}, auth=${authState.valueOrNull?.isAuthenticated}',
          name: 'Router'
      );

      // Extract auth status safely
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final isInitialized = authState.hasValue && !authState.isLoading;
      final isAuthRoute = state.location == '/login' || state.location == '/register';
      final isSplashRoute = state.location == '/';

      // Debug logging for router state
      developer.log(
          'Auth state: initialized=$isInitialized, authenticated=$isAuthenticated, route=${state.location}',
          name: 'Router'
      );

      // If still initializing, show splash screen
      if (!isInitialized && !isSplashRoute) {
        developer.log('Auth not initialized, redirecting to splash', name: 'Router');
        return '/';
      }

      // If authenticated and trying to access auth routes, redirect to home
      if (isAuthenticated && isAuthRoute) {
        developer.log('User authenticated but on auth route, redirecting to home', name: 'Router');
        return '/home';
      }

      // If not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated && !isAuthRoute && !isSplashRoute) {
        developer.log('User not authenticated, redirecting to login', name: 'Router');
        return '/login';
      }

      // No redirection needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'movie/:id',
                    name: 'movie_detail',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final movie = state.extra as Movie?;
                      return MovieDetailScreen(movieId: id, movie: movie);
                    },
                  ),
                  GoRoute(
                    path: 'tv/:id',
                    name: 'tv_detail',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final tvShow = state.extra as TvShow?;
                      return TvShowDetailScreen(tvShowId: id, tvShow: tvShow);
                    },
                  ),
                  GoRoute(
                    path: 'tv/:id/season/:seasonNumber',
                    name: 'tv_season',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final seasonNumber = int.parse(state.pathParameters['seasonNumber']!);
                      return TvShowSeasonScreen(tvShowId: id, seasonNumber: seasonNumber);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'movie/:id',
                    name: 'search_movie_detail',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final movie = state.extra as Movie?;
                      return MovieDetailScreen(movieId: id, movie: movie);
                    },
                  ),
                  GoRoute(
                    path: 'tv/:id',
                    name: 'search_tv_detail',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final tvShow = state.extra as TvShow?;
                      return TvShowDetailScreen(tvShowId: id, tvShow: tvShow);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
                routes: [
                  GoRoute(
                    path: 'movie/:id',
                    name: 'favorites_movie_detail',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final movie = state.extra as Movie?;
                      return MovieDetailScreen(movieId: id, movie: movie);
                    },
                  ),
                  GoRoute(
                    path: 'tv/:id',
                    name: 'favorites_tv_detail',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final tvShow = state.extra as TvShow?;
                      return TvShowDetailScreen(tvShowId: id, tvShow: tvShow);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                name: 'rewards',
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'watchlist',
                    name: 'watchlist',
                    builder: (context, state) => const WatchlistScreen(),
                    routes: [
                      GoRoute(
                        path: 'movie/:id',
                        name: 'watchlist_movie_detail',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          final movie = state.extra as Movie?;
                          return MovieDetailScreen(movieId: id, movie: movie);
                        },
                      ),
                      GoRoute(
                        path: 'tv/:id',
                        name: 'watchlist_tv_detail',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          final tvShow = state.extra as TvShow?;
                          return TvShowDetailScreen(tvShowId: id, tvShow: tvShow);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error?.toString() ?? "Unknown error"}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});