import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/core/errors/failure.dart';
import 'package:watch2earn/core/network/api_client.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/movies/models/movie_cast.dart';
import 'package:watch2earn/features/movies/models/movie_video.dart';
import 'package:watch2earn/features/movies/models/review.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page = 1});
  Future<Either<Failure, List<Movie>>> getPopular({int page = 1});
  Future<Either<Failure, List<Movie>>> getTrending({int page = 1});
  Future<Either<Failure, List<Movie>>> getUpcoming({int page = 1});
  Future<Either<Failure, Movie>> getMovieDetail(int movieId);
  Future<Either<Failure, List<Movie>>> getSimilar(int movieId, {int page = 1});
  Future<Either<Failure, List<Review>>> getReviews(int movieId, {int page = 1});
  Future<Either<Failure, List<MovieCast>>> getCredits(int movieId);
  Future<Either<Failure, List<MovieVideo>>> getVideos(int movieId);
  Future<Either<Failure, List<Movie>>> search(String query, {int page = 1});
}

class MovieRepositoryImpl implements MovieRepository {
  final ApiClient _apiClient;
  final Box<Movie> _movieBox;

  MovieRepositoryImpl({
    required ApiClient apiClient,
    required Box<Movie> movieBox,
  })  : _apiClient = apiClient,
        _movieBox = movieBox;

  @override
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'now_playing_$page';
      final cachedMovies = _getCachedMovies(cacheKey);
      if (cachedMovies.isNotEmpty) {
        return Right(cachedMovies);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.nowPlayingMovies,
        queryParameters: {'page': page},
      );

      final movies = (response['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();

      // Cache the results
      _cacheMovies(cacheKey, movies);

      return Right(movies);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopular({int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'popular_$page';
      final cachedMovies = _getCachedMovies(cacheKey);
      if (cachedMovies.isNotEmpty) {
        return Right(cachedMovies);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.popularMovies,
        queryParameters: {'page': page},
      );

      final movies = (response['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();

      // Cache the results
      _cacheMovies(cacheKey, movies);

      return Right(movies);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTrending({int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'trending_$page';
      final cachedMovies = _getCachedMovies(cacheKey);
      if (cachedMovies.isNotEmpty) {
        return Right(cachedMovies);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.trendingMovies,
        queryParameters: {'page': page},
      );

      final movies = (response['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();

      // Cache the results
      _cacheMovies(cacheKey, movies);

      return Right(movies);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getUpcoming({int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'upcoming_$page';
      final cachedMovies = _getCachedMovies(cacheKey);
      if (cachedMovies.isNotEmpty) {
        return Right(cachedMovies);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.upcomingMovies,
        queryParameters: {'page': page},
      );

      final movies = (response['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();

      // Cache the results
      _cacheMovies(cacheKey, movies);

      return Right(movies);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetail(int movieId) async {
    try {
      // Check cache first
      final cacheKey = 'movie_$movieId';
      final cachedMovie = _movieBox.get(cacheKey);
      if (cachedMovie != null) {
        return Right(cachedMovie);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.movieDetails.replaceAll('{movie_id}', movieId.toString()),
      );

      final movie = Movie.fromJson(response);

      // Cache the result
      _movieBox.put(cacheKey, movie);

      return Right(movie);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilar(int movieId, {int page = 1}) async {
    try {
      // Check cache first
      final cacheKey = 'similar_${movieId}_$page';
      final cachedMovies = _getCachedMovies(cacheKey);
      if (cachedMovies.isNotEmpty) {
        return Right(cachedMovies);
      }

      // Fetch from API
      final response = await _apiClient.get(
        AppConstants.similarMovies.replaceAll('{movie_id}', movieId.toString()),
        queryParameters: {'page': page},
      );

      final movies = (response['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();

      // Cache the results
      _cacheMovies(cacheKey, movies);

      return Right(movies);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getReviews(int movieId, {int page = 1}) async {
    try {
      final response = await _apiClient.get(
        AppConstants.movieReviews.replaceAll('{movie_id}', movieId.toString()),
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
  Future<Either<Failure, List<MovieCast>>> getCredits(int movieId) async {
    try {
      final response = await _apiClient.get(
        AppConstants.movieCredits.replaceAll('{movie_id}', movieId.toString()),
      );

      final cast = (response['cast'] as List)
          .map((actor) => MovieCast.fromJson(actor))
          .toList();

      return Right(cast);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MovieVideo>>> getVideos(int movieId) async {
    try {
      final response = await _apiClient.get(
        AppConstants.movieVideos.replaceAll('{movie_id}', movieId.toString()),
      );

      final videos = (response['results'] as List)
          .map((video) => MovieVideo.fromJson(video))
          .toList();

      return Right(videos);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> search(String query, {int page = 1}) async {
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
          .where((result) => result['media_type'] == 'movie')
          .map((movie) => Movie.fromJson(movie))
          .toList();

      return Right(results);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  List<Movie> _getCachedMovies(String cacheKey) {
    final movieList = <Movie>[];

    // Hive'da saklanan anahtarları kontrol et (örneğin: "trending_1_0", "trending_1_1", ...)
    for (final key in _movieBox.keys) {
      if (key is String && key.startsWith('${cacheKey}_')) {
        final movie = _movieBox.get(key);
        if (movie != null) {
          movieList.add(movie);
        }
      }
    }

    return movieList;
  }

  void _cacheMovies(String cacheKey, List<Movie> movies) {
    // Öncelikle eski önbellek verilerini temizle
    for (final key in _movieBox.keys.toList()) {
      if (key is String && key.startsWith('${cacheKey}_')) {
        _movieBox.delete(key);
      }
    }

    // Her filmi ayrı ayrı sakla
    for (int i = 0; i < movies.length; i++) {
      _movieBox.put('${cacheKey}_$i', movies[i]);
    }
  }
}
