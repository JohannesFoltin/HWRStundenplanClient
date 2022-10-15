// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vorlesung.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vorlesung _$VorlesungFromJson(Map<String, dynamic> json) => Vorlesung(
      json['Startzeit'] as int,
      json['Endzeit'] as int,
      json['Raum'] as String,
      json['Beschreibung'] as String,
    );

Map<String, dynamic> _$VorlesungToJson(Vorlesung instance) => <String, dynamic>{
      'Startzeit': instance.Startzeit,
      'Endzeit': instance.Endzeit,
      'Raum': instance.Raum,
      'Beschreibung': instance.Beschreibung,
    };
