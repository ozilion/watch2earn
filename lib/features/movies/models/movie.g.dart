// lib/features/movies/models/movie.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:hive/hive.dart';
import 'genre.dart';
import 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************


class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 1;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as int,
      title: fields[1] as String,
      overview: fields[2] as String?,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      genreIds: (fields[5] as List).cast<int>(),
      genres: (fields[6] as List?)?.cast<Genre>(),
      voteAverage: fields[7] as double,
      voteCount: fields[8] as int,
      releaseDate: fields[9] as DateTime?,
      originalLanguage: fields[10] as String?,
      adult: fields[11] as bool,
      popularity: fields[12] as double,
      video: fields[13] as bool,
      status: fields[14] as String?,
      runtime: fields[15] as int?,
      budget: fields[16] as int?,
      revenue: fields[17] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.overview)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.backdropPath)
      ..writeByte(5)
      ..write(obj.genreIds)
      ..writeByte(6)
      ..write(obj.genres)
      ..writeByte(7)
      ..write(obj.voteAverage)
      ..writeByte(8)
      ..write(obj.voteCount)
      ..writeByte(9)
      ..write(obj.releaseDate)
      ..writeByte(10)
      ..write(obj.originalLanguage)
      ..writeByte(11)
      ..write(obj.adult)
      ..writeByte(12)
      ..write(obj.popularity)
      ..writeByte(13)
      ..write(obj.video)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.runtime)
      ..writeByte(16)
      ..write(obj.budget)
      ..writeByte(17)
      ..write(obj.revenue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MovieAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}