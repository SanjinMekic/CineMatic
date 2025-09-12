// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Film _$FilmFromJson(Map<String, dynamic> json) => Film(
  id: (json['id'] as num?)?.toInt(),
  naziv: json['naziv'] as String?,
  trajanje: (json['trajanje'] as num?)?.toInt(),
  opis: json['opis'] as String?,
  slikaBase64: json['slikaBase64'] as String?,
  dobnaRestrikcijaId: (json['dobnaRestrikcijaId'] as num?)?.toInt(),
  dobnaRestrikcija:
      json['dobnaRestrikcija'] == null
          ? null
          : DobnaRestrikcija.fromJson(
            json['dobnaRestrikcija'] as Map<String, dynamic>,
          ),
  glumacs:
      (json['glumacs'] as List<dynamic>?)
          ?.map((e) => Glumac.fromJson(e as Map<String, dynamic>))
          .toList(),
  rezisers:
      (json['režisers'] as List<dynamic>?)
          ?.map((e) => Reziser.fromJson(e as Map<String, dynamic>))
          .toList(),
  zanrs:
      (json['žanrs'] as List<dynamic>?)
          ?.map((e) => Zanr.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$FilmToJson(Film instance) => <String, dynamic>{
  'id': instance.id,
  'naziv': instance.naziv,
  'trajanje': instance.trajanje,
  'opis': instance.opis,
  'slikaBase64': instance.slikaBase64,
  'dobnaRestrikcijaId': instance.dobnaRestrikcijaId,
  'dobnaRestrikcija': instance.dobnaRestrikcija?.toJson(),
  'glumacs': instance.glumacs?.map((e) => e.toJson()).toList(),
  'režisers': instance.rezisers?.map((e) => e.toJson()).toList(),
  'žanrs': instance.zanrs?.map((e) => e.toJson()).toList(),
};
