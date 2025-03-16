import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/movies/widgets/cast_list.dart';
import 'package:watch2earn/features/movies/widgets/movie_info_item.dart';
import 'package:watch2earn/features/movies/widgets/video_card.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';
import 'package:watch2earn/features/tv_shows/providers/tv_shows_provider.dart';
import 'package:watch2earn/features/tv_shows/widgets/season_card.dart';
import 'package:watch2earn/features/tv_shows/widgets/tv_show_card.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class TvShowDetailScreen extends ConsumerWidget {
  final int tvShowId;
  final TvShow? tvShow;

  const TvShowDetailScreen({
    Key? key,
    required this.tvShowId,
    this.tvShow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvShowDetail = ref.watch(tvShowDetailsProvider(tvShowId));
    
    return Scaffold(
      body: tvShowDetail.when(
        data: (tvShow) => _buildTvShowDetail(context, ref, tvShow),
        loading: () => _buildLoadingState(context, ref),
        error: (error, stack) => _buildErrorState(context, error, ref),
      ),
    );
  }

  Widget _buildTvShowDetail(BuildContext context, WidgetRef ref, TvShow tvShow) {
    final size = MediaQuery.of(context).size;
    
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, tvShow),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${tvShow.name} (${tvShow.year})',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    _buildFavoriteButton(context, ref, tvShow),
                    const SizedBox(width: 8),
                    _buildWatchlistButton(context, ref, tvShow),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Rating
                _buildRating(context, tvShow),
                const SizedBox(height: 16),
                
                // TV Show Info
                _buildTvShowInfo(context, tvShow),
                const SizedBox(height: 24),
                
                // Overview
                Text(
                  'movie.overview'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  tvShow.overview ?? 'No overview available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                
                // Seasons
                if (tvShow.seasons != null && tvShow.seasons!.isNotEmpty)
                  _buildSeasonsSection(context, tvShow),
                const SizedBox(height: 24),
                
                // Cast
                _buildCastSection(context, ref),
                const SizedBox(height: 24),
                
                // Videos
                _buildVideosSection(context, ref),
                const SizedBox(height: 24),
                
                // Similar TV Shows
                _buildSimilarTvShowsSection(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TvShow tvShow) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: tvShow.backdropPath != null
            ? CachedNetworkImage(
                imageUrl: tvShow.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.tv, size: 50, color: Colors.white54),
                ),
              )
            : Container(
                color: Colors.grey[900],
                child: const Icon(Icons.tv, size: 50, color: Colors.white54),
              ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, WidgetRef ref) {
    if (tvShow != null) {
      return _buildTvShowDetail(context, ref, tvShow!);
    }
    return const LoadingView();
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return ErrorView(
      message: error.toString(),
      onRetry: () => ref.refresh(tvShowDetailsProvider(tvShowId)),
    );
  }

  Widget _buildRating(BuildContext context, TvShow tvShow) {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: tvShow.voteAverage / 2,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 20,
          ignoreGestures: true,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: AppColors.ratingColor,
          ),
          onRatingUpdate: (_) {},
        ),
        const SizedBox(width: 8),
        Text(
          '${tvShow.voteAverage.toStringAsFixed(1)}/10',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        Text(
          '(${tvShow.voteCount})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildTvShowInfo(BuildContext context, TvShow tvShow) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        if (tvShow.numberOfSeasons != null)
          MovieInfoItem(
            icon: Icons.view_list,
            label: 'tv_show.seasons'.tr(),
            value: '${tvShow.numberOfSeasons}',
          ),
        if (tvShow.numberOfEpisodes != null)
          MovieInfoItem(
            icon: Icons.movie_filter,
            label: 'tv_show.episodes'.tr(),
            value: '${tvShow.numberOfEpisodes}',
          ),
        if (tvShow.firstAirDate != null)
          MovieInfoItem(
            icon: Icons.calendar_today,
            label: 'tv_show.first_air_date'.tr(),
            value: tvShow.formattedFirstAirDate,
          ),
        if (tvShow.lastAirDate != null)
          MovieInfoItem(
            icon: Icons.calendar_today,
            label: 'tv_show.last_air_date'.tr(),
            value: tvShow.formattedLastAirDate,
          ),
        if (tvShow.genres != null && tvShow.genres!.isNotEmpty)
          MovieInfoItem(
            icon: Icons.category,
            label: 'movie.genres'.tr(),
            value: tvShow.genres!.map((g) => g.name).join(', '),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context, WidgetRef ref, TvShow tvShow) {
    final isFavorite = false; // This would come from a provider
    
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
      onPressed: () {
        // Toggle favorite status
      },
      tooltip: isFavorite
          ? 'movie.remove_from_favorites'.tr()
          : 'movie.add_to_favorites'.tr(),
    );
  }

  Widget _buildWatchlistButton(BuildContext context, WidgetRef ref, TvShow tvShow) {
    final isInWatchlist = false; // This would come from a provider
    
    return IconButton(
      icon: Icon(
        isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
        color: isInWatchlist ? AppColors.primaryColor : null,
      ),
      onPressed: () {
        // Toggle watchlist status
      },
      tooltip: isInWatchlist
          ? 'movie.remove_from_watchlist'.tr()
          : 'movie.add_to_watchlist'.tr(),
    );
  }

  Widget _buildSeasonsSection(BuildContext context, TvShow tvShow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'tv_show.seasons'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (tvShow.numberOfSeasons != null && tvShow.numberOfSeasons! > 5)
              TextButton(
                onPressed: () {
                  // Navigate to all seasons screen
                },
                child: Text('general.see_all'.tr()),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tvShow.seasons?.length ?? 0,
            itemBuilder: (context, index) {
              final season = tvShow.seasons![index];
              return SeasonCard(
                season: season,
                tvShowId: tvShow.id,
                onTap: () => context.go('/home/tv/${tvShow.id}/season/${season.seasonNumber}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection(BuildContext context, WidgetRef ref) {
    final cast = ref.watch(tvShowCastProvider(tvShowId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'movie.cast'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        cast.when(
          data: (castList) => CastList(cast: castList),
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text('Error loading cast: $error'),
        ),
      ],
    );
  }

  Widget _buildVideosSection(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(tvShowVideosProvider(tvShowId));
    
    return videos.when(
      data: (videosList) {
        if (videosList.isEmpty) return const SizedBox();
        
        final trailers = videosList.where((v) => v.isTrailer).toList();
        final videosToShow = trailers.isNotEmpty ? trailers : videosList;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'movie.videos'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videosToShow.length,
                itemBuilder: (context, index) {
                  final video = videosToShow[index];
                  return VideoCard(
                    video: video,
                    onTap: () => _launchUrl(video.youtubeUrl),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (error, stack) => const SizedBox(),
    );
  }

  Widget _buildSimilarTvShowsSection(BuildContext context, WidgetRef ref) {
    final similarTvShows = ref.watch(similarTvShowsProvider(tvShowId));
    
    return similarTvShows.when(
      data: (tvShows) {
        if (tvShows.isEmpty) return const SizedBox();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'tv_show.similar'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tvShows.length,
                itemBuilder: (context, index) {
                  return TvShowCard(
                    tvShow: tvShows[index],
                    width: 130,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (error, stack) => const SizedBox(),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}