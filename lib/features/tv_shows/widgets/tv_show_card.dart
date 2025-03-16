import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';
import 'package:watch2earn/shared/widgets/rating_indicator.dart';

class TvShowCard extends StatelessWidget {
  final TvShow tvShow;
  final double width;
  final double? height;
  final bool showRating;
  final VoidCallback? onTap;

  const TvShowCard({
    Key? key,
    required this.tvShow,
    this.width = 140,
    this.height,
    this.showRating = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculatedHeight = height ?? width * 1.5;

    return GestureDetector(
      onTap: onTap ?? () => _navigateToTvShowDetail(context),
      child: Container(
        width: width,
        height: calculatedHeight,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Poster image
              Positioned.fill(
                child: tvShow.posterPath != null
                    ? CachedNetworkImage(
                        imageUrl: tvShow.posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.tv, size: 40),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.tv, size: 40),
                      ),
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
                      colors: AppColors.posterGradient,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TV show title
                      Text(
                        tvShow.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Year and rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tvShow.year,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
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
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTvShowDetail(BuildContext context) {
    context.go('/home/tv/${tvShow.id}', extra: tvShow);
  }
}
