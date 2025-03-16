import 'package:equatable/equatable.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/movies/models/genre.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<int> genreIds;
  final List<Genre>? genres;
  final double voteAverage;
  final int voteCount;
  final DateTime? releaseDate;
  final String? originalLanguage;
  final bool adult;
  final double popularity;
  final bool video;
  final String? status;
  final int? runtime;
  final int? budget;
  final int? revenue;

  const Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.genreIds = const [],
    this.genres,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.releaseDate,
    this.originalLanguage,
    this.adult = false,
    this.popularity = 0.0,
    this.video = false,
    this.status,
    this.runtime,
    this.budget,
    this.revenue,
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
    if (releaseDate == null) return '';
    return releaseDate!.year.toString();
  }

  String get formattedReleaseDate {
    if (releaseDate == null) return '';
    return '${releaseDate!.year}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}';
  }

  int get ratingPercentage {
    return (voteAverage * 10).round();
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

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
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
      releaseDate: json['release_date'] != null && json['release_date'] != ''
          ? DateTime.parse(json['release_date'] as String)
          : null,
      originalLanguage: json['original_language'] as String?,
      adult: json['adult'] as bool? ?? false,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      video: json['video'] as bool? ?? false,
      status: json['status'] as String?,
      runtime: json['runtime'] as int?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'genre_ids': genreIds,
      'genres': genres?.map((e) => e.toJson()).toList(),
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate?.toIso8601String(),
      'original_language': originalLanguage,
      'adult': adult,
      'popularity': popularity,
      'video': video,
      'status': status,
      'runtime': runtime,
      'budget': budget,
      'revenue': revenue,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        genreIds,
        genres,
        voteAverage,
        voteCount,
        releaseDate,
        originalLanguage,
        adult,
        popularity,
        video,
        status,
        runtime,
        budget,
        revenue,
      ];
}
