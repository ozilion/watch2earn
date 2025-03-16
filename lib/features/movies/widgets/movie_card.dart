// lib/features/movies/widgets/movie_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';
import 'package:watch2earn/features/movies/models/movie.dart';
import 'package:watch2earn/shared/widgets/rating_indicator.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double? height;
  final bool showRating;
  final VoidCallback? onTap;
  final bool showOverlay;
  final bool enableHero;

  const MovieCard({
    Key? key,
    required this.movie,
    this.width = 140,
    this.height,
    this.showRating = true,
    this.onTap,
    this.showOverlay = true,
    this.enableHero = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculatedHeight = height ?? width * 1.5;
    final theme = Theme.of(context);
    final cardBorderRadius = BorderRadius.circular(12);

    return GestureDetector(
      onTap: onTap ?? () => _navigateToMovieDetail(context),
      child: Container(
        width: width,
        height: calculatedHeight,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: cardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: cardBorderRadius,
          child: Stack(
            children: [
              // Poster image with hero animation for smooth transitions
              Positioned.fill(
                child: enableHero
                    ? Hero(
                  tag: 'movie-poster-${movie.id}',
                  child: _buildPosterImage(context),
                )
                    : _buildPosterImage(context),
              ),

              // Gradient overlay at bottom for better text readability
              if (showOverlay)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: calculatedHeight * 0.4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: AppColors.posterGradient,
                      ),
                    ),
                  ),
                ),

              // Movie info at bottom
              if (showOverlay)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie title
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Year and rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (movie.releaseDate != null)
                              Text(
                                movie.year,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            if (showRating)
                              RatingIndicator(
                                rating: movie.voteAverage,
                                size: 14,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Optional genre badge in top right
              if (movie.genres != null && movie.genres!.isNotEmpty && showOverlay)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      movie.genres![0].name,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage(BuildContext context) {
    return movie.posterPath != null
        ? CachedNetworkImage(
      imageUrl: movie.posterUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 32),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                movie.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        : Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie, size: 32),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              movie.title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMovieDetail(BuildContext context) {
    context.go('/home/movie/${movie.id}', extra: movie);
  }
}