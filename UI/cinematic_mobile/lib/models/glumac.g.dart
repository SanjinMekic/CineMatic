// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glumac.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Glumac _$GlumacFromJson(Map<String, dynamic> json) => Glumac(
  id: (json['id'] as num).toInt(),
  ime: json['ime'] as String?,
  prezime: json['prezime'] as String?,
  datumRodjenja:
      json['datumRodjenja'] == null
          ? null
          : DateTime.parse(json['datumRodjenja'] as String),
  opis: json['opis'] as String?,
  uspjesi: json['uspjesi'] as String?,
  ulogeUfilmovima: json['ulogeUfilmovima'] as String?,
  slikaBase64: json['slikaBase64'] as String?,
);

Map<String, dynamic> _$GlumacToJson(Glumac instance) => <String, dynamic>{
  'id': instance.id,
  'ime': instance.ime,
  'prezime': instance.prezime,
  'datumRodjenja': instance.datumRodjenja?.toIso8601String(),
  'opis': instance.opis,
  'uspjesi': instance.uspjesi,
  'ulogeUfilmovima': instance.ulogeUfilmovima,
  'slikaBase64': instance.slikaBase64,
};
