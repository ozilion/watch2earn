import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/features/home/providers/home_provider.dart';
import 'package:watch2earn/features/home/widgets/content_section.dart';
import 'package:watch2earn/features/home/widgets/home_banner.dart';
import 'package:watch2earn/features/home/widgets/section_header.dart';
import 'package:watch2earn/features/movies/providers/movies_provider.dart';
import 'package:watch2earn/features/movies/widgets/movie_card.dart';
import 'package:watch2earn/features/rewards/services/ad_manager.dart';
import 'package:watch2earn/features/tv_shows/providers/tv_shows_provider.dart';
import 'package:watch2earn/features/tv_shows/widgets/tv_show_card.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final AdManager _adManager = AdManager();

  @override
  void initState() {
    super.initState();
    _adManager.loadInterstitialAd();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    ref.read(trendingMoviesProvider.notifier).loadTrendingMovies();
    ref.read(popularMoviesProvider.notifier).loadPopularMovies();
    ref.read(upcomingMoviesProvider.notifier).loadUpcomingMovies();
    ref.read(trendingTvShowsProvider.notifier).loadTrendingTvShows();
    ref.read(popularTvShowsProvider.notifier).loadPopularTvShows();
  }

  void _onScroll() {
    // Show interstitial ad when scrolled more than 80% of the screen
    if (_scrollController.position.pixels >
        0.8 * _scrollController.position.maxScrollExtent) {
      _adManager.showInterstitialAd();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _adManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trendingMovies = ref.watch(trendingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);
    final trendingTvShows = ref.watch(trendingTvShowsProvider);
    final popularTvShows = ref.watch(popularTvShowsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialData();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeBanner(),
              
              // Trending Movies Section
              trendingMovies.when(
                data: (movies) {
                  if (movies.isEmpty) return Container();
                  return ContentSection(
                    header: SectionHeader(
                      title: 'home.trending_movies'.tr(),
                      onSeeAllPressed: () {
                        // Navigate to trending movies
                      },
                    ),
                    content: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: movies[index],
                            width: 130,
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 220,
                  child: ErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref.read(trendingMoviesProvider.notifier).loadTrendingMovies();
                    },
                  ),
                ),
              ),
              
              // Popular Movies Section
              popularMovies.when(
                data: (movies) {
                  if (movies.isEmpty) return Container();
                  return ContentSection(
                    header: SectionHeader(
                      title: 'home.popular_movies'.tr(),
                      onSeeAllPressed: () {
                        // Navigate to popular movies
                      },
                    ),
                    content: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: movies[index],
                            width: 130,
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 220,
                  child: ErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref.read(popularMoviesProvider.notifier).loadPopularMovies();
                    },
                  ),
                ),
              ),
              
              // Trending TV Shows Section
              trendingTvShows.when(
                data: (tvShows) {
                  if (tvShows.isEmpty) return Container();
                  return ContentSection(
                    header: SectionHeader(
                      title: 'home.trending_tv'.tr(),
                      onSeeAllPressed: () {
                        // Navigate to trending TV shows
                      },
                    ),
                    content: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tvShows.length,
                        itemBuilder: (context, index) {
                          return TvShowCard(
                            tvShow: tvShows[index],
                            width: 130,
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 220,
                  child: ErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref.read(trendingTvShowsProvider.notifier).loadTrendingTvShows();
                    },
                  ),
                ),
              ),
              
              // Upcoming Movies Section
              upcomingMovies.when(
                data: (movies) {
                  if (movies.isEmpty) return Container();
                  return ContentSection(
                    header: SectionHeader(
                      title: 'home.upcoming_movies'.tr(),
                      onSeeAllPressed: () {
                        // Navigate to upcoming movies
                      },
                    ),
                    content: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: movies[index],
                            width: 130,
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 220,
                  child: ErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref.read(upcomingMoviesProvider.notifier).loadUpcomingMovies();
                    },
                  ),
                ),
              ),
              
              // Popular TV Shows Section
              popularTvShows.when(
                data: (tvShows) {
                  if (tvShows.isEmpty) return Container();
                  return ContentSection(
                    header: SectionHeader(
                      title: 'home.popular_tv'.tr(),
                      onSeeAllPressed: () {
                        // Navigate to popular TV shows
                      },
                    ),
                    content: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tvShows.length,
                        itemBuilder: (context, index) {
                          return TvShowCard(
                            tvShow: tvShows[index],
                            width: 130,
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 220,
                  child: ErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref.read(popularTvShowsProvider.notifier).loadPopularTvShows();
                    },
                  ),
                ),
              ),
              
              // Show banner ad at the bottom
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: _adManager.getBannerAd(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
