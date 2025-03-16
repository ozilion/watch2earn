import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch2earn/features/home/providers/home_provider.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';

import '../../movies/repositories/movie_repository.dart';
import '../../tv_shows/repositories/tv_show_repository.dart';

// Search Movies Provider
final searchMoviesProvider = StateNotifierProvider<SearchMoviesNotifier, AsyncValue<List<Movie>>>((ref) {
  final movieRepository = ref.watch(movieRepositoryProvider);
  return SearchMoviesNotifier(repository: movieRepository);
});

class SearchMoviesNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final MovieRepository _repository;

  SearchMoviesNotifier({required MovieRepository repository})
      : _repository = repository,
        super(const AsyncValue.data([]));

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.search(query);
      
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (movies) => state = AsyncValue.data(movies),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Search TV Shows Provider
final searchTvShowsProvider = StateNotifierProvider<SearchTvShowsNotifier, AsyncValue<List<TvShow>>>((ref) {
  final tvShowRepository = ref.watch(tvShowRepositoryProvider);
  return SearchTvShowsNotifier(repository: tvShowRepository);
});

class SearchTvShowsNotifier extends StateNotifier<AsyncValue<List<TvShow>>> {
  final TvShowRepository _repository;

  SearchTvShowsNotifier({required TvShowRepository repository})
      : _repository = repository,
        super(const AsyncValue.data([]));

  Future<void> searchTvShows(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.search(query);
      
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (tvShows) => state = AsyncValue.data(tvShows),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Search History Provider
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, AsyncValue<List<String>>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<String>>> {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxRecentSearches = 10;
  
  SearchHistoryNotifier() : super(const AsyncValue.loading());

  Future<void> loadSearchHistory() async {
    state = const AsyncValue.loading();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
      
      state = AsyncValue.data(searchHistory);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addSearch(String query) async {
    if (query.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
      
      // Remove the query if it already exists
      searchHistory.remove(query);
      
      // Add the query at the beginning of the list
      searchHistory.insert(0, query);
      
      // Limit the list size
      if (searchHistory.length > _maxRecentSearches) {
        searchHistory = searchHistory.sublist(0, _maxRecentSearches);
      }
      
      // Save the updated list
      await prefs.setStringList(_searchHistoryKey, searchHistory);
      
      state = AsyncValue.data(searchHistory);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> removeSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
      
      // Remove the query
      searchHistory.remove(query);
      
      // Save the updated list
      await prefs.setStringList(_searchHistoryKey, searchHistory);
      
      state = AsyncValue.data(searchHistory);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear the search history
      await prefs.setStringList(_searchHistoryKey, []);
      
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
