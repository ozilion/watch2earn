import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/core/errors/failure.dart';
import 'package:watch2earn/core/network/api_client.dart';
import 'package:watch2earn/features/movies/models/review.dart';
import 'package:watch2earn/features/tv_shows/models/season.dart';
import 'package:watch2earn/features/tv_shows/models/tv_cast.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';
import 'package:watch2earn/features/tv_shows/models/tv_video.dart';

abstract class TvShowRepository {
  Future<Either<Failure, List<TvShow>>> getPopular({int page = 1});
  Future<Either<Failure, List<TvShow>>> getTrending({int page = 1});
  Future<Either<Failure, TvShow>> getTvShowDetail(int tvId);
  Future<Either<Failure, Season>> getSeason(int tvId, int seasonNumber);
  Future<Either<Failure, List<TvShow>>> getSimilar(int tvId, {int page = 1});
  Future<Either<Failure, List<Review>>> getReviews(int tvId, {int page = 1});
  Future<Either<Failure, List<TvCast>>> getCredits(int tvId);
  Future<Either<Failure, List<TvVideo>>> getVideos(int tvId);
  Future<Either<Failure, List<TvShow>>> search(String query, {int page = 1});
}

class TvShowRepositoryImpl implements TvShowRepository {
  final ApiClient _apiClient;
  final Box<TvShow> _tvShowBox;
  final Box<Season> _seasonBox;

  TvShowRepositoryImpl({
    required ApiClient apiClient,
    required Box<TvShow> tvShowBox,
    required Box<Season> seasonBox,
  })  : _apiClient = apiClient,
        _tvShowBox = tvShowBox,
        _seasonBox = seasonBox;

  @override
  Future<Either<Failure, List<TvShow>>> getPopular({int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'popular_tv_$page';
      final cachedShows = _getCachedTvShows(cacheKey);
      if (cachedShows.isNotEmpty) {
        return Right(cachedShows);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.popularTvShows,
        queryParameters: {'page': page},
      );

      final shows = (response['results'] as List)
          .map((show) => TvShow.fromJson(show))
          .toList();

      // Cache the results
      _cacheTvShows(cacheKey, shows);

      return Right(shows);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TvShow>>> getTrending({int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'trending_tv_$page';
      final cachedShows = _getCachedTvShows(cacheKey);
      if (cachedShows.isNotEmpty) {
        return Right(cachedShows);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.trendingTvShows,
        queryParameters: {'page': page},
      );

      final shows = (response['results'] as List)
          .map((show) => TvShow.fromJson(show))
          .toList();

      // Cache the results
      _cacheTvShows(cacheKey, shows);

      return Right(shows);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TvShow>> getTvShowDetail(int tvId) async {
    try {
      // Check cache first
      final cacheKey = 'tv_$tvId';
      final cachedShow = _tvShowBox.get(cacheKey);
      if (cachedShow != null) {
        return Right(cachedShow);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.tvShowDetails.replaceAll('{tv_id}', tvId.toString()),
      );

      final show = TvShow.fromJson(response);

      // Cache the result
      _tvShowBox.put(cacheKey, show);

      return Right(show);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Season>> getSeason(int tvId, int seasonNumber) async {
    try {
      // Check cache first
      final cacheKey = 'tv_${tvId}_season_$seasonNumber';
      final cachedSeason = _seasonBox.get(cacheKey);
      if (cachedSeason != null) {
        return Right(cachedSeason);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.tvShowSeasons
            .replaceAll('{tv_id}', tvId.toString())
            .replaceAll('{season_number}', seasonNumber.toString()),
      );

      final season = Season.fromJson(response);

      // Cache the result
      _seasonBox.put(cacheKey, season);

      return Right(season);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TvShow>>> getSimilar(int tvId, {int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'similar_tv_${tvId}_$page';
      final cachedShows = _getCachedTvShows(cacheKey);
      if (cachedShows.isNotEmpty) {
        return Right(cachedShows);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.similarTvShows.replaceAll('{tv_id}', tvId.toString()),
        queryParameters: {'page': page},
      );

      final shows = (response['results'] as List)
          .map((show) => TvShow.fromJson(show))
          .toList();

      // Cache the results
      _cacheTvShows(cacheKey, shows);

      return Right(shows);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getReviews(int tvId, {int page = 1}) async {
    try {
      final response = await _apiClient.get(
        AppConstants.tvShowReviews.replaceAll('{tv_id}', tvId.toString()),
        queryParameters: {'page': page},
      );

      final reviews = (response['results'] as List)
          .map((review) => Review.fromJson(review))
          .toList();

      return Right(reviews);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TvCast>>> getCredits(int tvId) async {
    try {
      final response = await _apiClient.get(
        AppConstants.tvShowCredits.replaceAll('{tv_id}', tvId.toString()),
      );

      final cast = (response['cast'] as List)
          .map((actor) => TvCast.fromJson(actor))
          .toList();

      return Right(cast);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TvVideo>>> getVideos(int tvId) async {
    try {
      final response = await _apiClient.get(
        AppConstants.tvShowVideos.replaceAll('{tv_id}', tvId.toString()),
      );

      final videos = (response['results'] as List)
          .map((video) => TvVideo.fromJson(video))
          .toList();

      return Right(videos);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TvShow>>> search(String query, {int page = 1}) async {
    try {
      final response = await _apiClient.get(
        AppConstants.search,
        queryParameters: {
          'query': query,
          'page': page,
          'include_adult': false,
        },
      );

      final results = (response['results'] as List)
          .where((result) => result['media_type'] == 'tv')
          .map((show) => TvShow.fromJson(show))
          .toList();

      return Right(results);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  List<TvShow> _getCachedTvShows(String cacheKey) {
    final showList = <TvShow>[];

    // Hive'da saklanan anahtarları kontrol et (örneğin: "trending_1_0", "trending_1_1", ...)
    for (final key in _tvShowBox.keys) {
      if (key is String && key.startsWith('${cacheKey}_')) {
        final show = _tvShowBox.get(key);
        if (show != null) {
          showList.add(show);
        }
      }
    }

    return showList;
  }

  void _cacheTvShows(String cacheKey, List<TvShow> shows) {
    // Öncelikle eski önbellek verilerini temizle
    for (final key in _tvShowBox.keys.toList()) {
      if (key is String && key.startsWith('${cacheKey}_')) {
        _tvShowBox.delete(key);
      }
    }

    // Her filmi ayrı ayrı sakla
    for (int i = 0; i < shows.length; i++) {
      _tvShowBox.put('${cacheKey}_$i', shows[i]);
    }
  }
}
