import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';

// Watchlist Movies Provider
final watchlistMoviesProvider = StateNotifierProvider<WatchlistMoviesNotifier, AsyncValue<List<Movie>>>((ref) {
  final box = Hive.box<Movie>(AppConstants.watchlistMoviesBox);
  final authController = ref.watch(authControllerProvider.notifier);
  return WatchlistMoviesNotifier(
    box: box,
    authController: authController,
  );
});

class WatchlistMoviesNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final Box<Movie> _box;
  final AuthController _authController;

  WatchlistMoviesNotifier({
    required Box<Movie> box,
    required AuthController authController,
  })  : _box = box,
        _authController = authController,
        super(const AsyncValue.loading());

  Future<void> loadWatchlistMovies() async {
    state = const AsyncValue.loading();
    
    try {
      final user = _authController.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final watchlistMovies = _getUserWatchlistMovies(user.id);
      state = AsyncValue.data(watchlistMovies);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleWatchlist(Movie movie) async {
    try {
      final user = _authController.currentUser;
      if (user == null) return;
      
      final key = '${user.id}_${movie.id}';
      final exists = _box.containsKey(key);
      
      if (exists) {
        await _box.delete(key);
      } else {
        await _box.put(key, movie);
      }
      
      // Reload watchlist
      final watchlistMovies = _getUserWatchlistMovies(user.id);
      state = AsyncValue.data(watchlistMovies);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  bool isInWatchlist(int movieId) {
    final user = _authController.currentUser;
    if (user == null) return false;
    
    final key = '${user.id}_$movieId';
    return _box.containsKey(key);
  }

  List<Movie> _getUserWatchlistMovies(String userId) {
    final List<Movie> watchlistMovies = [];
    
    for (final key in _box.keys) {
      if (key is String && key.startsWith('${userId}_')) {
        final movie = _box.get(key);
        if (movie != null) {
          watchlistMovies.add(movie);
        }
      }
    }
    
    return watchlistMovies;
  }
}

// Watchlist TV Shows Provider
final watchlistTvShowsProvider = StateNotifierProvider<WatchlistTvShowsNotifier, AsyncValue<List<TvShow>>>((ref) {
  final box = Hive.box<TvShow>(AppConstants.watchlistTvShowsBox);
  final authController = ref.watch(authControllerProvider.notifier);
  return WatchlistTvShowsNotifier(
    box: box,
    authController: authController,
  );
});

class WatchlistTvShowsNotifier extends StateNotifier<AsyncValue<List<TvShow>>> {
  final Box<TvShow> _box;
  final AuthController _authController;

  WatchlistTvShowsNotifier({
    required Box<TvShow> box,
    required AuthController authController,
  })  : _box = box,
        _authController = authController,
        super(const AsyncValue.loading());

  Future<void> loadWatchlistTvShows() async {
    state = const AsyncValue.loading();
    
    try {
      final user = _authController.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final watchlistTvShows = _getUserWatchlistTvShows(user.id);
      state = AsyncValue.data(watchlistTvShows);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleWatchlist(TvShow tvShow) async {
    try {
      final user = _authController.currentUser;
      if (user == null) return;
      
      final key = '${user.id}_${tvShow.id}';
      final exists = _box.containsKey(key);
      
      if (exists) {
        await _box.delete(key);
      } else {
        await _box.put(key, tvShow);
      }
      
      // Reload watchlist
      final watchlistTvShows = _getUserWatchlistTvShows(user.id);
      state = AsyncValue.data(watchlistTvShows);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  bool isInWatchlist(int tvShowId) {
    final user = _authController.currentUser;
    if (user == null) return false;
    
    final key = '${user.id}_$tvShowId';
    return _box.containsKey(key);
  }

  List<TvShow> _getUserWatchlistTvShows(String userId) {
    final List<TvShow> watchlistTvShows = [];
    
    for (final key in _box.keys) {
      if (key is String && key.startsWith('${userId}_')) {
        final tvShow = _box.get(key);
        if (tvShow != null) {
          watchlistTvShows.add(tvShow);
        }
      }
    }
    
    return watchlistTvShows;
  }
}
