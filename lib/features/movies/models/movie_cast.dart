import 'package:equatable/equatable.dart';
import 'package:watch2earn/core/constants/app_constants.dart';

class MovieCast extends Equatable {
  final int id;
  final int castId;
  final String name;
  final String character;
  final String? profilePath;
  final int? order;
  final String? knownForDepartment;
  final int? gender;

  const MovieCast({
    required this.id,
    required this.castId,
    required this.name,
    required this.character,
    this.profilePath,
    this.order,
    this.knownForDepartment,
    this.gender,
  });

  String get profileUrl {
    if (profilePath == null) return '';
    return '${AppConstants.imageBaseUrl}/${AppConstants.profileSize}$profilePath';
  }

  factory MovieCast.fromJson(Map<String, dynamic> json) {
    return MovieCast(
      id: json['id'] as int,
      castId: json['cast_id'] as int,
      name: json['name'] as String,
      character: json['character'] as String,
      profilePath: json['profile_path'] as String?,
      order: json['order'] as int?,
      knownForDepartment: json['known_for_department'] as String?,
      gender: json['gender'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cast_id': castId,
      'name': name,
      'character': character,
      'profile_path': profilePath,
      'order': order,
      'known_for_department': knownForDepartment,
      'gender': gender,
    };
  }

  @override
  List<Object?> get props => [
        id,
        castId,
        name,
        character,
        profilePath,
        order,
        knownForDepartment,
        gender,
      ];
}
