import 'package:equatable/equatable.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/movies/models/genre.dart';
import 'package:watch2earn/features/tv_shows/models/season.dart';

class TvShow extends Equatable {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<int> genreIds;
  final List<Genre>? genres;
  final double voteAverage;
  final int voteCount;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final String? originalLanguage;
  final double popularity;
  final String? status;
  final List<Season>? seasons;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? type;
  final List<String>? originCountry;

  const TvShow({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.genreIds = const [],
    this.genres,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.firstAirDate,
    this.lastAirDate,
    this.originalLanguage,
    this.popularity = 0.0,
    this.status,
    this.seasons,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.type,
    this.originCountry,
  });

  String get posterUrl {
    if (posterPath == null) return '';
    return '${AppConstants.imageBaseUrl}/${AppConstants.posterSize}$posterPath';
  }

  String get backdropUrl {
    if (backdropPath == null) return '';
    return '${AppConstants.imageBaseUrl}/${AppConstants.backdropSize}$backdropPath';
  }

  String get year {
    if (firstAirDate == null) return '';
    return firstAirDate!.year.toString();
  }

  String get formattedFirstAirDate {
    if (firstAirDate == null) return '';
    return '${firstAirDate!.year}-${firstAirDate!.month.toString().padLeft(2, '0')}-${firstAirDate!.day.toString().padLeft(2, '0')}';
  }

  String get formattedLastAirDate {
    if (lastAirDate == null) return '';
    return '${lastAirDate!.year}-${lastAirDate!.month.toString().padLeft(2, '0')}-${lastAirDate!.day.toString().padLeft(2, '0')}';
  }

  int get ratingPercentage {
    return (voteAverage * 10).round();
  }

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'] as int,
      name: json['name'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          null,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      firstAirDate: json['first_air_date'] != null && json['first_air_date'] != ''
          ? DateTime.parse(json['first_air_date'] as String)
          : null,
      lastAirDate: json['last_air_date'] != null && json['last_air_date'] != ''
          ? DateTime.parse(json['last_air_date'] as String)
          : null,
      originalLanguage: json['original_language'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String?,
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
              .toList() ??
          null,
      numberOfSeasons: json['number_of_seasons'] as int?,
      numberOfEpisodes: json['number_of_episodes'] as int?,
      type: json['type'] as String?,
      originCountry: (json['origin_country'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'genre_ids': genreIds,
      'genres': genres?.map((e) => e.toJson()).toList(),
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'first_air_date': firstAirDate?.toIso8601String(),
      'last_air_date': lastAirDate?.toIso8601String(),
      'original_language': originalLanguage,
      'popularity': popularity,
      'status': status,
      'seasons': seasons?.map((e) => e.toJson()).toList(),
      'number_of_seasons': numberOfSeasons,
      'number_of_episodes': numberOfEpisodes,
      'type': type,
      'origin_country': originCountry,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        overview,
        posterPath,
        backdropPath,
        genreIds,
        genres,
        voteAverage,
        voteCount,
        firstAirDate,
        lastAirDate,
        originalLanguage,
        popularity,
        status,
        seasons,
        numberOfSeasons,
        numberOfEpisodes,
        type,
        originCountry,
      ];
}
