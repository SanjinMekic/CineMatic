// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija_film_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RezervacijaFilmDTO _$RezervacijaFilmDTOFromJson(Map<String, dynamic> json) =>
    RezervacijaFilmDTO(
      rezervacijaId: (json['rezervacijaId'] as num?)?.toInt(),
      datumRezervacije:
          json['datumRezervacije'] == null
              ? null
              : DateTime.parse(json['datumRezervacije'] as String),
      nacinPlacanja: json['nacinPlacanja'] as String?,
      projekcijaId: (json['projekcijaId'] as num?)?.toInt(),
      datumProjekcije:
          json['datumProjekcije'] == null
              ? null
              : DateTime.parse(json['datumProjekcije'] as String),
      sjedistaIds:
          (json['sjedistaIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      hranaPiceIds:
          (json['hranaPiceIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      filmId: (json['filmId'] as num?)?.toInt(),
      nazivFilma: json['nazivFilma'] as String?,
      trajanjeFilma: (json['trajanjeFilma'] as num?)?.toInt(),
      opis: json['opis'] as String?,
      filmaSlikaBase64: json['filmaSlikaBase64'] as String?,
    );

Map<String, dynamic> _$RezervacijaFilmDTOToJson(RezervacijaFilmDTO instance) =>
    <String, dynamic>{
      'rezervacijaId': instance.rezervacijaId,
      'datumRezervacije': instance.datumRezervacije?.toIso8601String(),
      'nacinPlacanja': instance.nacinPlacanja,
      'projekcijaId': instance.projekcijaId,
      'datumProjekcije': instance.datumProjekcije?.toIso8601String(),
      'sjedistaIds': instance.sjedistaIds,
      'hranaPiceIds': instance.hranaPiceIds,
      'filmId': instance.filmId,
      'nazivFilma': instance.nazivFilma,
      'trajanjeFilma': instance.trajanjeFilma,
      'opis': instance.opis,
      'filmaSlikaBase64': instance.filmaSlikaBase64,
    };
