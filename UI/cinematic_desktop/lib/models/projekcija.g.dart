// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projekcija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Projekcija _$ProjekcijaFromJson(Map<String, dynamic> json) => Projekcija(
  id: (json['id'] as num?)?.toInt(),
  filmId: (json['filmId'] as num?)?.toInt(),
  salaId: (json['salaId'] as num?)?.toInt(),
  nacinProjekcijeId: (json['načinProjekcijeId'] as num?)?.toInt(),
  datumIvrijeme:
      json['datumIvrijeme'] == null
          ? null
          : DateTime.parse(json['datumIvrijeme'] as String),
  cijena: (json['cijena'] as num?)?.toDouble(),
  stanje: json['stanje'] as String?,
  film:
      json['film'] == null
          ? null
          : Film.fromJson(json['film'] as Map<String, dynamic>),
  nacinProjekcije:
      json['načinProjekcije'] == null
          ? null
          : NacinPrikazivanja.fromJson(
            json['načinProjekcije'] as Map<String, dynamic>,
          ),
  sala:
      json['sala'] == null
          ? null
          : Sala.fromJson(json['sala'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProjekcijaToJson(Projekcija instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filmId': instance.filmId,
      'salaId': instance.salaId,
      'načinProjekcijeId': instance.nacinProjekcijeId,
      'datumIvrijeme': instance.datumIvrijeme?.toIso8601String(),
      'cijena': instance.cijena,
      'stanje': instance.stanje,
      'film': instance.film?.toJson(),
      'načinProjekcije': instance.nacinProjekcije?.toJson(),
      'sala': instance.sala?.toJson(),
    };
