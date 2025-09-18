// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preporuceni_film.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreporuceniFilm _$PreporuceniFilmFromJson(
  Map<String, dynamic> json,
) => PreporuceniFilm(
  id: (json['id'] as num).toInt(),
  naslov: json['naslov'] as String,
  zanrovi: (json['zanrovi'] as List<dynamic>).map((e) => e as String).toList(),
  glumci: (json['glumci'] as List<dynamic>).map((e) => e as String).toList(),
  imageBase64: json['imageBase64'] as String?,
);

Map<String, dynamic> _$PreporuceniFilmToJson(PreporuceniFilm instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naslov': instance.naslov,
      'zanrovi': instance.zanrovi,
      'glumci': instance.glumci,
      'imageBase64': instance.imageBase64,
    };
