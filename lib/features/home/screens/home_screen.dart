import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _isAdCountdownVisible = false;

  @override
  void initState() {
    super.initState();

    // Load ad manager
    _adManager.loadBannerAd();
    _adManager.loadInterstitialAd();
    _adManager.loadRewardedAd();

    // Initialize by loading initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    // Listen to countdown to show ad notification widget
    _listenToAdCountdown();
  }

  void _loadInitialData() {
    ref.read(trendingMoviesProvider.notifier).loadTrendingMovies();
    ref.read(popularMoviesProvider.notifier).loadPopularMovies();
    ref.read(upcomingMoviesProvider.notifier).loadUpcomingMovies();
    ref.read(trendingTvShowsProvider.notifier).loadTrendingTvShows();
    ref.read(popularTvShowsProvider.notifier).loadPopularTvShows();
  }

  void _listenToAdCountdown() {
    _adManager.adCountdown.listen((countdown) {
      // Show countdown widget when less than 60 seconds remain
      final shouldShow = countdown <= 60;
      if (shouldShow != _isAdCountdownVisible && mounted) {
        setState(() {
          _isAdCountdownVisible = shouldShow;
        });
      }
    });
  }

  // Track when a movie or TV show is selected
  void _onContentSelected(BuildContext context, dynamic item, String route) {
    // Track the interaction to potentially show an ad after threshold is reached
    _adManager.trackContentInteraction();

    // Navigate to the content
    if (context.mounted) {
      context.go(route, extra: item);
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
              context.go('/search');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content with RefreshIndicator
          Column(
            children: [
              // Scrollable content
              Expanded(
                child: RefreshIndicator(
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
                                      onTap: () => _onContentSelected(
                                          context,
                                          movies[index],
                                          '/home/movie/${movies[index].id}'
                                      ),
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
                                      onTap: () => _onContentSelected(
                                          context,
                                          movies[index],
                                          '/home/movie/${movies[index].id}'
                                      ),
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
                                      onTap: () => _onContentSelected(
                                          context,
                                          tvShows[index],
                                          '/home/tv/${tvShows[index].id}'
                                      ),
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
                                      onTap: () => _onContentSelected(
                                          context,
                                          movies[index],
                                          '/home/movie/${movies[index].id}'
                                      ),
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
                                      onTap: () => _onContentSelected(
                                          context,
                                          tvShows[index],
                                          '/home/tv/${tvShows[index].id}'
                                      ),
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

                        // Add bottom padding to ensure content is visible above the banner ad
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
              ),

              // Banner Ad - always at the bottom of the screen
              Container(
                width: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                height: 60, // Fixed height for banner
                child: _adManager.getBannerAd(),
              ),
            ],
          ),

          // Countdown notification for next scheduled ad
          if (_isAdCountdownVisible)
            Positioned(
              bottom: 70, // Position above the banner ad
              right: 10,
              child: _adManager.getAdCountdownWidget(),
            ),
        ],
      ),
    );
  }
}