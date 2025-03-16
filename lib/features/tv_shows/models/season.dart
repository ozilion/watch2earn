import 'package:equatable/equatable.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/tv_shows/models/episode.dart';

class Season extends Equatable {
  final int id;
  final String name;
  final int seasonNumber;
  final int? episodeCount;
  final String? overview;
  final String? posterPath;
  final DateTime? airDate;
  final List<Episode>? episodes;

  const Season({
    required this.id,
    required this.name,
    required this.seasonNumber,
    this.episodeCount,
    this.overview,
    this.posterPath,
    this.airDate,
    this.episodes,
  });

  String get posterUrl {
    if (posterPath == null) return '';
    return '${AppConstants.imageBaseUrl}/${AppConstants.posterSize}$posterPath';
  }

  String get formattedAirDate {
    if (airDate == null) return '';
    return '${airDate!.year}-${airDate!.month.toString().padLeft(2, '0')}-${airDate!.day.toString().padLeft(2, '0')}';
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as int,
      name: json['name'] as String,
      seasonNumber: json['season_number'] as int,
      episodeCount: json['episode_count'] as int?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      airDate: json['air_date'] != null && json['air_date'] != ''
          ? DateTime.parse(json['air_date'] as String)
          : null,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'season_number': seasonNumber,
      'episode_count': episodeCount,
      'overview': overview,
      'poster_path': posterPath,
      'air_date': airDate?.toIso8601String(),
      'episodes': episodes?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        seasonNumber,
        episodeCount,
        overview,
        posterPath,
        airDate,
        episodes,
      ];
}
