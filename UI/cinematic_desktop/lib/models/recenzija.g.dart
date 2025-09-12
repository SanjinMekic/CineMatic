// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recenzija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recenzija _$RecenzijaFromJson(Map<String, dynamic> json) => Recenzija(
  id: (json['id'] as num?)?.toInt(),
  korisnikId: (json['korisnikId'] as num?)?.toInt(),
  filmId: (json['filmId'] as num?)?.toInt(),
  ocjena: (json['ocjena'] as num?)?.toInt(),
  datumIvrijeme:
      json['datumIvrijeme'] == null
          ? null
          : DateTime.parse(json['datumIvrijeme'] as String),
  komentar: json['komentar'] as String?,
  film:
      json['film'] == null
          ? null
          : Film.fromJson(json['film'] as Map<String, dynamic>),
  korisnik:
      json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RecenzijaToJson(Recenzija instance) => <String, dynamic>{
  'id': instance.id,
  'korisnikId': instance.korisnikId,
  'filmId': instance.filmId,
  'ocjena': instance.ocjena,
  'datumIvrijeme': instance.datumIvrijeme?.toIso8601String(),
  'komentar': instance.komentar,
  'film': instance.film?.toJson(),
  'korisnik': instance.korisnik?.toJson(),
};
