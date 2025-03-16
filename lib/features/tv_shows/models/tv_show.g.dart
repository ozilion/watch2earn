// lib/features/tv_shows/models/tv_show.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND


// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

import 'package:hive/hive.dart';
import 'package:watch2earn/features/tv_shows/models/season.dart';
import 'package:watch2earn/features/tv_shows/models/tv_show.dart';

import '../../movies/models/genre.dart';

class TvShowAdapter extends TypeAdapter<TvShow> {
  @override
  final int typeId = 2;

  @override
  TvShow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TvShow(
      id: fields[0] as int,
      name: fields[1] as String,
      overview: fields[2] as String?,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      genreIds: (fields[5] as List).cast<int>(),
      genres: (fields[6] as List?)?.cast<Genre>(),
      voteAverage: fields[7] as double,
      voteCount: fields[8] as int,
      firstAirDate: fields[9] as DateTime?,
      lastAirDate: fields[10] as DateTime?,
      originalLanguage: fields[11] as String?,
      popularity: fields[12] as double,
      status: fields[13] as String?,
      seasons: (fields[14] as List?)?.cast<Season>(),
      numberOfSeasons: fields[15] as int?,
      numberOfEpisodes: fields[16] as int?,
      type: fields[17] as String?,
      originCountry: (fields[18] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TvShow obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
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
      ..write(obj.firstAirDate)
      ..writeByte(10)
      ..write(obj.lastAirDate)
      ..writeByte(11)
      ..write(obj.originalLanguage)
      ..writeByte(12)
      ..write(obj.popularity)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.seasons)
      ..writeByte(15)
      ..write(obj.numberOfSeasons)
      ..writeByte(16)
      ..write(obj.numberOfEpisodes)
      ..writeByte(17)
      ..write(obj.type)
      ..writeByte(18)
      ..write(obj.originCountry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TvShowAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}