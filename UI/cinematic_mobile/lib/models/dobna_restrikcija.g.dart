// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dobna_restrikcija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DobnaRestrikcija _$DobnaRestrikcijaFromJson(Map<String, dynamic> json) =>
    DobnaRestrikcija(
      id: (json['id'] as num).toInt(),
      restrikcija: json['restrikcija'] as String?,
      opis: json['opis'] as String?,
    );

Map<String, dynamic> _$DobnaRestrikcijaToJson(DobnaRestrikcija instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restrikcija': instance.restrikcija,
      'opis': instance.opis,
    };
