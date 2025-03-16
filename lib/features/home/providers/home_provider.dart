import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/core/network/api_client.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/movies/repositories/movie_repository.dart';
import 'package:watch2earn/features/tv_shows/models/season.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';
import 'package:watch2earn/features/tv_shows/repositories/tv_show_repository.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Hive Boxes Providers
final movieBoxProvider = Provider<Box<Movie>>((ref) {
  return Hive.box<Movie>(AppConstants.moviesBox); // ✅ Ensure Hive box is opened
});

final tvShowBoxProvider = Provider<Box<TvShow>>((ref) {
  return Hive.box<TvShow>(AppConstants.tvShowsBox); // ✅ Ensure Hive box is opened
});

final seasonBoxProvider = Provider<Box<Season>>((ref) {
  return Hive.box<Season>(AppConstants.seasonBox); // ✅ Ensure Hive box is opened
});


// Movie Repository Provider
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final movieBox = ref.read(movieBoxProvider);
  return MovieRepositoryImpl(
    apiClient: apiClient,
    movieBox: movieBox,
  );
});

// TV Show Repository Provider
final tvShowRepositoryProvider = Provider<TvShowRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final tvShowBox = ref.read(tvShowBoxProvider);
  final seasonBox = ref.read(seasonBoxProvider);
  return TvShowRepositoryImpl(
    apiClient: apiClient,
    tvShowBox: tvShowBox,
    seasonBox: seasonBox,
  );
});
