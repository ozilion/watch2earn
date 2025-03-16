import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/features/home/providers/home_provider.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/movies/models/movie_cast.dart';
import 'package:watch2earn/features/movies/models/movie_video.dart';
import 'package:watch2earn/features/movies/models/review.dart';

import '../repositories/movie_repository.dart';

// Movies Providers
final trendingMoviesProvider = StateNotifierProvider<MoviesNotifier, AsyncValue<List<Movie>>>((ref) {
  final repository = ref.read(movieRepositoryProvider); // ✅ Use read instead of watch
  return MoviesNotifier(repository: repository);
});

final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, AsyncValue<List<Movie>>>((ref) {
  final repository = ref.read(movieRepositoryProvider); // ✅ Use read instead of watch
  return MoviesNotifier(repository: repository);
});

final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, AsyncValue<List<Movie>>>((ref) {
  final repository = ref.read(movieRepositoryProvider); // ✅ Use read instead of watch
  return MoviesNotifier(repository: repository);
});


// Movie Details Providers
final movieDetailsProvider = FutureProvider.family<Movie, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getMovieDetail(movieId);
  return result.fold(
    (failure) => throw failure,
    (movie) => movie,
  );
});

final movieCastProvider = FutureProvider.family<List<MovieCast>, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getCredits(movieId);
  return result.fold(
    (failure) => throw failure,
    (cast) => cast,
  );
});

final movieVideosProvider = FutureProvider.family<List<MovieVideo>, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getVideos(movieId);
  return result.fold(
    (failure) => throw failure,
    (videos) => videos,
  );
});

final movieReviewsProvider = FutureProvider.family<List<Review>, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getReviews(movieId);
  return result.fold(
    (failure) => throw failure,
    (reviews) => reviews,
  );
});

final similarMoviesProvider = FutureProvider.family<List<Movie>, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getSimilar(movieId);
  return result.fold(
    (failure) => throw failure,
    (movies) => movies,
  );
});

// Movies Notifier
class MoviesNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final MovieRepository _repository;
  int _page = 1;
  bool _hasMore = true;

  MoviesNotifier({required MovieRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading());

  Future<void> loadTrendingMovies({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh) return;

    try {
      final result = await _repository.getTrending(page: _page);

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (movies) {
          if (movies.isEmpty) {
            _hasMore = false;
            return;
          }

          if (_page == 1) {
            state = AsyncValue.data(movies);
          } else {
            state = AsyncValue.data([...state.valueOrNull ?? [], ...movies]);
          }

          _page++;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadPopularMovies({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh) return;

    try {
      final result = await _repository.getPopular(page: _page);

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (movies) {
          if (movies.isEmpty) {
            _hasMore = false;
            return;
          }

          if (_page == 1) {
            state = AsyncValue.data(movies);
          } else {
            state = AsyncValue.data([...state.valueOrNull ?? [], ...movies]);
          }

          _page++;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadUpcomingMovies({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh) return;

    try {
      final result = await _repository.getUpcoming(page: _page);

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (movies) {
          if (movies.isEmpty) {
            _hasMore = false;
            return;
          }

          if (_page == 1) {
            state = AsyncValue.data(movies);
          } else {
            state = AsyncValue.data([...state.valueOrNull ?? [], ...movies]);
          }

          _page++;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}