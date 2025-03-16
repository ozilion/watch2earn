// lib/features/tv_shows/models/season.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'season.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

import 'package:hive/hive.dart';
import 'package:watch2earn/features/tv_shows/models/season.dart';

import 'episode.dart';

class SeasonAdapter extends TypeAdapter<Season> {
  @override
  final int typeId = 3;

  @override
  Season read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Season(
      id: fields[0] as int,
      name: fields[1] as String,
      seasonNumber: fields[2] as int,
      episodeCount: fields[3] as int?,
      overview: fields[4] as String?,
      posterPath: fields[5] as String?,
      airDate: fields[6] as DateTime?,
      episodes: (fields[7] as List?)?.cast<Episode>(),
    );
  }

  @override
  void write(BinaryWriter writer, Season obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.seasonNumber)
      ..writeByte(3)
      ..write(obj.episodeCount)
      ..writeByte(4)
      ..write(obj.overview)
      ..writeByte(5)
      ..write(obj.posterPath)
      ..writeByte(6)
      ..write(obj.airDate)
      ..writeByte(7)
      ..write(obj.episodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SeasonAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}