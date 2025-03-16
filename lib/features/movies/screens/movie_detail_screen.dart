import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/features/movies/providers/movies_provider.dart';
import 'package:watch2earn/features/movies/widgets/cast_list.dart';
import 'package:watch2earn/features/movies/widgets/movie_card.dart';
import 'package:watch2earn/features/movies/widgets/movie_info_item.dart';
import 'package:watch2earn/features/movies/widgets/video_card.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;
  final Movie? movie;

  const MovieDetailScreen({
    Key? key,
    required this.movieId,
    this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetail = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      body: movieDetail.when(
        data: (movie) => _buildMovieDetail(context, ref, movie),
        loading: () => _buildLoadingState(context, ref),  // ref parametresini gönder
        error: (error, stack) => _buildErrorState(context, error, ref),
      ),
    );
  }

  Widget _buildMovieDetail(BuildContext context, WidgetRef ref, Movie movie) {
    final size = MediaQuery.of(context).size;
    
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, movie),
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
                        '${movie.title} (${movie.year})',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    _buildFavoriteButton(context, ref, movie),
                    const SizedBox(width: 8),
                    _buildWatchlistButton(context, ref, movie),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Rating
                _buildRating(context, movie),
                const SizedBox(height: 16),
                
                // Movie Info
                _buildMovieInfo(context, movie),
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
                  movie.overview ?? 'No overview available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                
                // Cast
                _buildCastSection(context, ref),
                const SizedBox(height: 24),
                
                // Videos
                _buildVideosSection(context, ref),
                const SizedBox(height: 24),
                
                // Similar Movies
                _buildSimilarMoviesSection(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Movie movie) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: movie.backdropPath != null
            ? CachedNetworkImage(
                imageUrl: movie.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.movie, size: 50, color: Colors.white54),
                ),
              )
            : Container(
                color: Colors.grey[900],
                child: const Icon(Icons.movie, size: 50, color: Colors.white54),
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
    if (movie != null) {
      return _buildMovieDetail(context, ref, movie!);
    }
    return const LoadingView();
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return ErrorView(
      message: error.toString(),
      onRetry: () => ref.refresh(movieDetailsProvider(movieId)),
    );
  }

  Widget _buildRating(BuildContext context, Movie movie) {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: movie.voteAverage / 2,
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
          '${movie.voteAverage.toStringAsFixed(1)}/10',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        Text(
          '(${movie.voteCount})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildMovieInfo(BuildContext context, Movie movie) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        if (movie.runtime != null)
          MovieInfoItem(
            icon: Icons.access_time,
            label: 'movie.runtime'.tr(),
            value: movie.formattedRuntime,
          ),
        if (movie.releaseDate != null)
          MovieInfoItem(
            icon: Icons.calendar_today,
            label: 'movie.release_date'.tr(),
            value: movie.formattedReleaseDate,
          ),
        if (movie.genres != null && movie.genres!.isNotEmpty)
          MovieInfoItem(
            icon: Icons.category,
            label: 'movie.genres'.tr(),
            value: movie.genres!.map((g) => g.name).join(', '),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context, WidgetRef ref, Movie movie) {
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

  Widget _buildWatchlistButton(BuildContext context, WidgetRef ref, Movie movie) {
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

  Widget _buildCastSection(BuildContext context, WidgetRef ref) {
    final cast = ref.watch(movieCastProvider(movieId));
    
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
            height: 135,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text('Error loading cast: $error'),
        ),
      ],
    );
  }

  Widget _buildVideosSection(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(movieVideosProvider(movieId));
    
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

  Widget _buildSimilarMoviesSection(BuildContext context, WidgetRef ref) {
    final similarMovies = ref.watch(similarMoviesProvider(movieId));
    
    return similarMovies.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'movie.similar'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: movies[index],
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
