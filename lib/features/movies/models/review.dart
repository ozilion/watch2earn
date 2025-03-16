import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String author;
  final String? authorUsername;
  final String? avatarPath;
  final double? rating;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String url;

  const Review({
    required this.id,
    required this.author,
    this.authorUsername,
    this.avatarPath,
    this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
  });

  String get avatarUrl {
    if (avatarPath == null) return '';
    if (avatarPath!.startsWith('/')) {
      return 'https://image.tmdb.org/t/p/w45$avatarPath';
    } else {
      return avatarPath!;
    }
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] as Map<String, dynamic>?;
    
    return Review(
      id: json['id'] as String,
      author: json['author'] as String,
      authorUsername: authorDetails?['username'] as String?,
      avatarPath: authorDetails?['avatar_path'] as String?,
      rating: authorDetails?['rating'] != null
          ? (authorDetails!['rating'] as num).toDouble()
          : null,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'author_details': {
        'username': authorUsername,
        'avatar_path': avatarPath,
        'rating': rating,
      },
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'url': url,
    };
  }

  @override
  List<Object?> get props => [
        id,
        author,
        authorUsername,
        avatarPath,
        rating,
        content,
        createdAt,
        updatedAt,
        url,
      ];
}
