import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/movies/widgets/movie_card.dart';
import 'package:watch2earn/features/search/providers/search_provider.dart';
import 'package:watch2earn/features/search/widgets/recent_search_item.dart';
import 'package:watch2earn/features/search/widgets/search_results_view.dart';
import 'package:watch2earn/features/tv_shows/widgets/tv_show_card.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecentSearches();
    
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty && _searchController.text.length > 2) {
        _performSearch();
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadRecentSearches() {
    ref.read(searchHistoryProvider.notifier).loadSearchHistory();
  }
  
  void _performSearch() {
    setState(() {
      _isSearching = true;
    });
    
    final query = _searchController.text.trim();
    if (query.length < 3) return;
    
    ref.read(searchMoviesProvider.notifier).searchMovies(query);
    ref.read(searchTvShowsProvider.notifier).searchTvShows(query);
    
    // Add to search history
    ref.read(searchHistoryProvider.notifier).addSearch(query);
  }
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
    });
  }
  
  void _onSearchHistoryItemTap(String query) {
    _searchController.text = query;
    _performSearch();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final searchHistory = ref.watch(searchHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
        ],
        bottom: _isSearching
            ? TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'search.movies'.tr()),
                  Tab(text: 'search.tv_shows'.tr()),
                ],
              )
            : null,
      ),
      body: _isSearching
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildMovieSearchResults(),
                _buildTvShowSearchResults(),
              ],
            )
          : _buildRecentSearches(searchHistory),
    );
  }
  
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'search.hint'.tr(),
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
            : null,
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          _performSearch();
        }
      },
    );
  }
  
  Widget _buildRecentSearches(AsyncValue<List<String>> searchHistory) {
    return searchHistory.when(
      data: (searches) {
        if (searches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'search.hint'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'search.recent_searches'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => ref.read(searchHistoryProvider.notifier).clearSearchHistory(),
                    child: Text('search.clear_history'.tr()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searches.length,
                itemBuilder: (context, index) {
                  return RecentSearchItem(
                    query: searches[index],
                    onTap: () => _onSearchHistoryItemTap(searches[index]),
                    onDelete: () => ref.read(searchHistoryProvider.notifier).removeSearch(searches[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: _loadRecentSearches,
      ),
    );
  }
  
  Widget _buildMovieSearchResults() {
    final searchResults = ref.watch(searchMoviesProvider);
    
    return searchResults.when(
      data: (movies) {
        if (movies.isEmpty) {
          return Center(
            child: Text('search.no_results'.tr()),
          );
        }
        
        return SearchResultsView(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return MovieCard(
              movie: movies[index],
              width: 150,
            );
          },
        );
      },
      loading: () => const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: _performSearch,
      ),
    );
  }
  
  Widget _buildTvShowSearchResults() {
    final searchResults = ref.watch(searchTvShowsProvider);
    
    return searchResults.when(
      data: (tvShows) {
        if (tvShows.isEmpty) {
          return Center(
            child: Text('search.no_results'.tr()),
          );
        }
        
        return SearchResultsView(
          itemCount: tvShows.length,
          itemBuilder: (context, index) {
            return TvShowCard(
              tvShow: tvShows[index],
              width: 150,
            );
          },
        );
      },
      loading: () => const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: _performSearch,
      ),
    );
  }
}
