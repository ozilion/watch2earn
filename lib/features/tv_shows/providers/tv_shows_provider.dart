import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/features/home/providers/home_provider.dart';
import 'package:watch2earn/features/movies/models/review.dart';
import 'package:watch2earn/features/tv_shows/models/season.dart';
import 'package:watch2earn/features/tv_shows/models/tv_cast.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';
import 'package:watch2earn/features/tv_shows/models/tv_video.dart';

import '../repositories/tv_show_repository.dart';

// TV Shows Providers
final trendingTvShowsProvider = StateNotifierProvider<TvShowsNotifier, AsyncValue<List<TvShow>>>((ref) {
  final repository = ref.watch(tvShowRepositoryProvider);
  return TvShowsNotifier(repository: repository);
});

final popularTvShowsProvider = StateNotifierProvider<TvShowsNotifier, AsyncValue<List<TvShow>>>((ref) {
  final repository = ref.watch(tvShowRepositoryProvider);
  return TvShowsNotifier(repository: repository);
});

// TV Show Details Providers
final tvShowDetailsProvider = FutureProvider.family<TvShow, int>((ref, tvShowId) async {
  final repository = ref.watch(tvShowRepositoryProvider);
  final result = await repository.getTvShowDetail(tvShowId);
  return result.fold(
    (failure) => throw failure,
    (tvShow) => tvShow,
  );
});

// Provider tanımını değiştirin
final tvShowSeasonProvider = FutureProvider.family<Season, SeasonParams>((ref, params) async {
  final repository = ref.watch(tvShowRepositoryProvider);
  final result = await repository.getSeason(params.tvShowId, params.seasonNumber);
  return result.fold(
        (failure) => throw failure,
        (season) => season,
  );
});

final tvShowCastProvider = FutureProvider.family<List<TvCast>, int>((ref, tvShowId) async {
  final repository = ref.watch(tvShowRepositoryProvider);
  final result = await repository.getCredits(tvShowId);
  return result.fold(
    (failure) => throw failure,
    (cast) => cast,
  );
});

final tvShowVideosProvider = FutureProvider.family<List<TvVideo>, int>((ref, tvShowId) async {
  final repository = ref.watch(tvShowRepositoryProvider);
  final result = await repository.getVideos(tvShowId);
  return result.fold(
    (failure) => throw failure,
    (videos) => videos,
  );
});

final tvShowReviewsProvider = FutureProvider.family<List<Review>, int>((ref, tvShowId) async {
  final repository = ref.watch(tvShowRepositoryProvider);
  final result = await repository.getReviews(tvShowId);
  return result.fold(
    (failure) => throw failure,
    (reviews) => reviews,
  );
});

final similarTvShowsProvider = FutureProvider.family<List<TvShow>, int>((ref, tvShowId) async {
  final repository = ref.watch(tvShowRepositoryProvider);
  final result = await repository.getSimilar(tvShowId);
  return result.fold(
    (failure) => throw failure,
    (tvShows) => tvShows,
  );
});

// TV Shows Notifier
class TvShowsNotifier extends StateNotifier<AsyncValue<List<TvShow>>> {
  final TvShowRepository _repository;
  int _page = 1;
  bool _hasMore = true;

  TvShowsNotifier({required TvShowRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading());

  Future<void> loadTrendingTvShows({bool refresh = false}) async {
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
        (tvShows) {
          if (tvShows.isEmpty) {
            _hasMore = false;
            return;
          }

          if (_page == 1) {
            state = AsyncValue.data(tvShows);
          } else {
            state = AsyncValue.data([...state.valueOrNull ?? [], ...tvShows]);
          }

          _page++;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadPopularTvShows({bool refresh = false}) async {
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
        (tvShows) {
          if (tvShows.isEmpty) {
            _hasMore = false;
            return;
          }

          if (_page == 1) {
            state = AsyncValue.data(tvShows);
          } else {
            state = AsyncValue.data([...state.valueOrNull ?? [], ...tvShows]);
          }

          _page++;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Özel bir sınıf oluşturun
class SeasonParams {
  final int tvShowId;
  final int seasonNumber;

  const SeasonParams({required this.tvShowId, required this.seasonNumber});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SeasonParams &&
              runtimeType == other.runtimeType &&
              tvShowId == other.tvShowId &&
              seasonNumber == other.seasonNumber;

  @override
  int get hashCode => tvShowId.hashCode ^ seasonNumber.hashCode;
}