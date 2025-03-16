import 'package:flutter/material.dart';

class AppConstants {
  // API URLs
  static const String backendBaseUrl = 'https://watch2earn.qms.com.tr/api';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';
  
  // API Endpoints
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String popularMovies = '/movie/popular';
  static const String upcomingMovies = '/movie/upcoming';
  static const String trendingMovies = '/trending/movie/week';
  static const String movieDetails = '/movie/{movie_id}';
  static const String movieCredits = '/movie/{movie_id}/credits';
  static const String movieReviews = '/movie/{movie_id}/reviews';
  static const String similarMovies = '/movie/{movie_id}/similar';
  static const String movieVideos = '/movie/{movie_id}/videos';
  
  static const String popularTvShows = '/tv/popular';
  static const String trendingTvShows = '/trending/tv/week';
  static const String tvShowDetails = '/tv/{tv_id}';
  static const String tvShowCredits = '/tv/{tv_id}/credits';
  static const String tvShowReviews = '/tv/{tv_id}/reviews';
  static const String similarTvShows = '/tv/{tv_id}/similar';
  static const String tvShowVideos = '/tv/{tv_id}/videos';
  static const String tvShowSeasons = '/tv/{tv_id}/season/{season_number}';
  
  static const String search = '/search/multi';
  
  // Hive Box Names
  static const String settingsBox = 'settingsBox';
  static const String favoriteMoviesBox = 'favoriteMoviesBox';
  static const String watchlistMoviesBox = 'watchlistMoviesBox';
  static const String favoriteTvShowsBox = 'favoriteTvShowsBox';
  static const String watchlistTvShowsBox = 'watchlistTvShowsBox';
  static const String searchHistoryBox = 'searchHistoryBox';
  static const String moviesBox = 'moviesBox';
  static const String tvShowsBox = 'tvShowsBox';
  static const String seasonBox = 'seasonsBox';

  // Secure Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  
  // Settings Keys
  static const String themeModeKey = 'theme_mode';
  static const String languageCodeKey = 'language_code';
  
  // Token Values
  static const double adRewardAmount = 5.0;
  static const int adIntervalMinutes = 15;
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Localization
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('it'),
  ];
  
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 200);
  
  // Cache durations
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration tokenRefreshInterval = Duration(hours: 1);
}
