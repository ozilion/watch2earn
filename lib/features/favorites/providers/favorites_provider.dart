import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';

// Favorite Movies Provider
final favoriteMoviesProvider = StateNotifierProvider<FavoriteMoviesNotifier, AsyncValue<List<Movie>>>((ref) {
  final box = Hive.box<Movie>(AppConstants.favoriteMoviesBox);
  final authController = ref.watch(authControllerProvider.notifier);
  return FavoriteMoviesNotifier(
    box: box,
    authController: authController,
  );
});

class FavoriteMoviesNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final Box<Movie> _box;
  final AuthController _authController;

  FavoriteMoviesNotifier({
    required Box<Movie> box,
    required AuthController authController,
  })  : _box = box,
        _authController = authController,
        super(const AsyncValue.loading());

  Future<void> loadFavoriteMovies() async {
    state = const AsyncValue.loading();
    
    try {
      final user = _authController.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final favoriteMovies = _getUserFavoriteMovies(user.id);
      state = AsyncValue.data(favoriteMovies);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
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
      
      // Reload favorites
      final favoriteMovies = _getUserFavoriteMovies(user.id);
      state = AsyncValue.data(favoriteMovies);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  bool isFavorite(int movieId) {
    final user = _authController.currentUser;
    if (user == null) return false;
    
    final key = '${user.id}_$movieId';
    return _box.containsKey(key);
  }

  List<Movie> _getUserFavoriteMovies(String userId) {
    final List<Movie> favoriteMovies = [];
    
    for (final key in _box.keys) {
      if (key is String && key.startsWith('${userId}_')) {
        final movie = _box.get(key);
        if (movie != null) {
          favoriteMovies.add(movie);
        }
      }
    }
    
    return favoriteMovies;
  }
}

// Favorite TV Shows Provider
final favoriteTvShowsProvider = StateNotifierProvider<FavoriteTvShowsNotifier, AsyncValue<List<TvShow>>>((ref) {
  final box = Hive.box<TvShow>(AppConstants.favoriteTvShowsBox);
  final authController = ref.watch(authControllerProvider.notifier);
  return FavoriteTvShowsNotifier(
    box: box,
    authController: authController,
  );
});

class FavoriteTvShowsNotifier extends StateNotifier<AsyncValue<List<TvShow>>> {
  final Box<TvShow> _box;
  final AuthController _authController;

  FavoriteTvShowsNotifier({
    required Box<TvShow> box,
    required AuthController authController,
  })  : _box = box,
        _authController = authController,
        super(const AsyncValue.loading());

  Future<void> loadFavoriteTvShows() async {
    state = const AsyncValue.loading();
    
    try {
      final user = _authController.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final favoriteTvShows = _getUserFavoriteTvShows(user.id);
      state = AsyncValue.data(favoriteTvShows);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(TvShow tvShow) async {
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
      
      // Reload favorites
      final favoriteTvShows = _getUserFavoriteTvShows(user.id);
      state = AsyncValue.data(favoriteTvShows);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  bool isFavorite(int tvShowId) {
    final user = _authController.currentUser;
    if (user == null) return false;
    
    final key = '${user.id}_$tvShowId';
    return _box.containsKey(key);
  }

  List<TvShow> _getUserFavoriteTvShows(String userId) {
    final List<TvShow> favoriteTvShows = [];
    
    for (final key in _box.keys) {
      if (key is String && key.startsWith('${userId}_')) {
        final tvShow = _box.get(key);
        if (tvShow != null) {
          favoriteTvShows.add(tvShow);
        }
      }
    }
    
    return favoriteTvShows;
  }
}
