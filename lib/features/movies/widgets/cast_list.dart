import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watch2earn/features/movies/models/movie_cast.dart';
import 'package:watch2earn/features/tv_shows/models/tv_cast.dart';

class CastList extends StatelessWidget {
  final List<dynamic> cast;
  
  const CastList({
    Key? key, 
    required this.cast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final actor = cast[index];
          String profileUrl;
          String name;
          String character;
          
          if (actor is MovieCast) {
            profileUrl = actor.profileUrl;
            name = actor.name;
            character = actor.character;
          } else if (actor is TvCast) {
            profileUrl = actor.profileUrl;
            name = actor.name;
            character = actor.character;
          } else {
            return const SizedBox();
          }
          
          return CastCard(
            imageUrl: profileUrl,
            name: name,
            character: character,
          );
        },
      ),
    );
  }
}

class CastCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String character;
  
  const CastCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.character,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: imageUrl.isNotEmpty
                ? CachedNetworkImageProvider(imageUrl)
                : null,
            backgroundColor: Colors.grey[300],
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}
