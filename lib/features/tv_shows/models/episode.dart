import 'package:equatable/equatable.dart';
import 'package:watch2earn/core/constants/app_constants.dart';

class Episode extends Equatable {
  final int id;
  final String name;
  final int episodeNumber;
  final int seasonNumber;
  final String? overview;
  final String? stillPath;
  final DateTime? airDate;
  final double voteAverage;
  final int voteCount;
  final int? runtime;
  final String? productionCode;

  const Episode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.seasonNumber,
    this.overview,
    this.stillPath,
    this.airDate,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.runtime,
    this.productionCode,
  });

  String get stillUrl {
    if (stillPath == null) return '';
    return '${AppConstants.imageBaseUrl}/${AppConstants.backdropSize}$stillPath';
  }

  String get formattedAirDate {
    if (airDate == null) return '';
    return '${airDate!.year}-${airDate!.month.toString().padLeft(2, '0')}-${airDate!.day.toString().padLeft(2, '0')}';
  }

  String get formattedRuntime {
    if (runtime == null) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  int get ratingPercentage {
    return (voteAverage * 10).round();
  }

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name'] as String,
      episodeNumber: json['episode_number'] as int,
      seasonNumber: json['season_number'] as int,
      overview: json['overview'] as String?,
      stillPath: json['still_path'] as String?,
      airDate: json['air_date'] != null && json['air_date'] != ''
          ? DateTime.parse(json['air_date'] as String)
          : null,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      runtime: json['runtime'] as int?,
      productionCode: json['production_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'episode_number': episodeNumber,
      'season_number': seasonNumber,
      'overview': overview,
      'still_path': stillPath,
      'air_date': airDate?.toIso8601String(),
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'runtime': runtime,
      'production_code': productionCode,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        episodeNumber,
        seasonNumber,
        overview,
        stillPath,
        airDate,
        voteAverage,
        voteCount,
        runtime,
        productionCode,
      ];
}
