import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/tv_shows/models/episode.dart';
import 'package:watch2earn/features/tv_shows/models/season.dart';
import 'package:watch2earn/features/tv_shows/providers/tv_shows_provider.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class TvShowSeasonScreen extends ConsumerWidget {
  final int tvShowId;
  final int seasonNumber;

  const TvShowSeasonScreen({
    Key? key,
    required this.tvShowId,
    required this.seasonNumber,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvShowDetail = ref.watch(tvShowDetailsProvider(tvShowId));
    final seasonDetail = ref.watch(tvShowSeasonProvider(
      SeasonParams(tvShowId: tvShowId, seasonNumber: seasonNumber),
    ));

    // Show loading if either TV show details or season details are loading
    if (tvShowDetail.isLoading || seasonDetail.isLoading) {
      return const Scaffold(
        body: LoadingView(),
      );
    }

    // Show error if either TV show details or season details have error
    if (tvShowDetail.hasError || seasonDetail.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text('tv_show.season'.tr() + ' $seasonNumber'),
        ),
        body: ErrorView(
          message: tvShowDetail.hasError
              ? tvShowDetail.error.toString()
              : seasonDetail.error.toString(),
          onRetry: () {
            if (tvShowDetail.hasError) {
              ref.refresh(tvShowDetailsProvider(tvShowId));
            }
            if (seasonDetail.hasError) {
              ref.refresh(tvShowSeasonProvider(
                SeasonParams(tvShowId: tvShowId, seasonNumber: seasonNumber),
              ));
            }
          },
        ),
      );
    }

    final tvShow = tvShowDetail.value;
    final season = seasonDetail.value;

    return Scaffold(
      appBar: AppBar(
        title: Text('${tvShow?.name} - ${season?.name}'),
      ),
      body: _buildSeasonDetail(context, season),
    );
  }

  Widget _buildSeasonDetail(BuildContext context, Season? season) {
    if (season == null) {
      return Center(
        child: Text('Season not found'),
      );
    }
    
    return Column(
      children: [
        // Season header
        _buildSeasonHeader(context, season),
        
        // Season episodes
        Expanded(
          child: _buildEpisodesList(context, season),
        ),
      ],
    );
  }

  Widget _buildSeasonHeader(BuildContext context, Season season) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Season poster
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: season.posterPath != null
                ? CachedNetworkImage(
                    imageUrl: season.posterUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.tv, size: 40),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.tv, size: 40),
                  ),
          ),
          const SizedBox(width: 16),
          
          // Season info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${season.episodeCount ?? 0} ${season.episodeCount == 1 ? 'tv_show.episode'.tr() : 'tv_show.episodes'.tr()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (season.airDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'tv_show.first_air_date'.tr() + ': ' + season.formattedAirDate,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 8),
                if (season.overview != null && season.overview!.isNotEmpty)
                  Text(
                    season.overview!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesList(BuildContext context, Season season) {
    if (season.episodes == null || season.episodes!.isEmpty) {
      return Center(
        child: Text('No episodes available'),
      );
    }
    
    return ListView.builder(
      itemCount: season.episodes!.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final episode = season.episodes![index];
        return _buildEpisodeItem(context, episode);
      },
    );
  }

  Widget _buildEpisodeItem(BuildContext context, Episode episode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode still image
          if (episode.stillPath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: episode.stillUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  height: 180,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  height: 180,
                  child: const Icon(Icons.movie, size: 40),
                ),
              ),
            ),
          
          // Episode info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Episode number and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${episode.episodeNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        episode.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Air date and runtime
                Row(
                  children: [
                    if (episode.airDate != null) ...[
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        episode.formattedAirDate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (episode.runtime != null) ...[
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        episode.formattedRuntime,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                
                // Overview
                if (episode.overview != null && episode.overview!.isNotEmpty) ...[
                  Text(
                    episode.overview!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Rating
                if (episode.voteAverage > 0) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.ratingColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${episode.voteAverage.toStringAsFixed(1)}/10',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}