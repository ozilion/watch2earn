import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/features/favorites/widgets/empty_favorites.dart';
import 'package:watch2earn/features/movies/widgets/movie_card.dart';
import 'package:watch2earn/features/tv_shows/widgets/tv_show_card.dart';
import 'package:watch2earn/features/watchlist/providers/watchlist_provider.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // Tab selection changed
      setState(() {});
    }
  }

  void _loadData() {
    ref.read(watchlistMoviesProvider.notifier).loadWatchlistMovies();
    ref.read(watchlistTvShowsProvider.notifier).loadWatchlistTvShows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('watchlist.title'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'search.movies'.tr()),
            Tab(text: 'search.tv_shows'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoviesTab(),
          _buildTvShowsTab(),
        ],
      ),
    );
  }

  Widget _buildMoviesTab() {
    final watchlistMovies = ref.watch(watchlistMoviesProvider);
    
    return watchlistMovies.when(
      data: (movies) {
        if (movies.isEmpty) {
          return EmptyFavorites(
            message: 'watchlist.empty'.tr(),
            subMessage: 'watchlist.add_some'.tr(),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return MovieCard(
              movie: movies[index],
              width: double.infinity,
            );
          },
        );
      },
      loading: () => const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.read(watchlistMoviesProvider.notifier).loadWatchlistMovies(),
      ),
    );
  }

  Widget _buildTvShowsTab() {
    final watchlistTvShows = ref.watch(watchlistTvShowsProvider);
    
    return watchlistTvShows.when(
      data: (tvShows) {
        if (tvShows.isEmpty) {
          return EmptyFavorites(
            message: 'watchlist.empty'.tr(),
            subMessage: 'watchlist.add_some'.tr(),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: tvShows.length,
          itemBuilder: (context, index) {
            return TvShowCard(
              tvShow: tvShows[index],
              width: double.infinity,
            );
          },
        );
      },
      loading: () => const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.read(watchlistTvShowsProvider.notifier).loadWatchlistTvShows(),
      ),
    );
  }
}
