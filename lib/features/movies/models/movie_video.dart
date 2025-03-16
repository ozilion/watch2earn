import 'package:equatable/equatable.dart';

class MovieVideo extends Equatable {
  final String id;
  final String name;
  final String key;
  final String site;
  final String type;
  final bool official;
  final DateTime publishedAt;
  final String iso6391;
  final String iso31661;

  const MovieVideo({
    required this.id,
    required this.name,
    required this.key,
    required this.site,
    required this.type,
    required this.official,
    required this.publishedAt,
    required this.iso6391,
    required this.iso31661,
  });

  String get youtubeUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://www.youtube.com/watch?v=$key';
    }
    return '';
  }

  String get thumbnailUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://img.youtube.com/vi/$key/hqdefault.jpg';
    }
    return '';
  }

  bool get isTrailer {
    return type.toLowerCase() == 'trailer';
  }

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      site: json['site'] as String,
      type: json['type'] as String,
      official: json['official'] as bool,
      publishedAt: DateTime.parse(json['published_at'] as String),
      iso6391: json['iso_639_1'] as String,
      iso31661: json['iso_3166_1'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key,
      'site': site,
      'type': type,
      'official': official,
      'published_at': publishedAt.toIso8601String(),
      'iso_639_1': iso6391,
      'iso_3166_1': iso31661,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        key,
        site,
        type,
        official,
        publishedAt,
        iso6391,
        iso31661,
      ];
}
