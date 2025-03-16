import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';
import 'package:watch2earn/shared/widgets/rating_indicator.dart';

class TvShowCard extends StatelessWidget {
  final TvShow tvShow;
  final double width;
  final double? height;
  final bool showRating;
  final VoidCallback? onTap;
  final bool enableHero;

  const TvShowCard({
    Key? key,
    required this.tvShow,
    this.width = 140,
    this.height,
    this.showRating = true,
    this.onTap,
    this.enableHero = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculatedHeight = height ?? width * 1.5;
    final theme = Theme.of(context);
    final cardBorderRadius = BorderRadius.circular(12);

    return GestureDetector(
      onTap: onTap ?? () => _navigateToTvShowDetail(context),
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
              // Poster image
              Positioned.fill(
                child: enableHero
                    ? Hero(
                  tag: 'tv-show-poster-${tvShow.id}',
                  child: _buildPosterImage(context),
                )
                    : _buildPosterImage(context),
              ),

              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: calculatedHeight * 0.4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                        Colors.black87,
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // TV show info at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TV show title
                      Text(
                        tvShow.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Year and rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (tvShow.firstAirDate != null)
                            Text(
                              tvShow.year,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                shadows: [
                                  const Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2.0,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          if (showRating)
                            RatingIndicator(
                              rating: tvShow.voteAverage,
                              size: 14,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Optional TV Show type badge
              if (tvShow.type != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      tvShow.type!,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tv, size: 32),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              tvShow.name,
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

    return tvShow.posterPath != null
        ? CachedNetworkImage(
      imageUrl: tvShow.posterUrl,
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
      errorWidget: (context, url, error) => placeholder,
    )
        : placeholder;
  }

  void _navigateToTvShowDetail(BuildContext context) {
    context.go('/home/tv/${tvShow.id}', extra: tvShow);
  }
}