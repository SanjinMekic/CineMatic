// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija_hrana_pice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RezervacijaHranaPice _$RezervacijaHranaPiceFromJson(
  Map<String, dynamic> json,
) => RezervacijaHranaPice(
  rezervacijaId: (json['rezervacijaId'] as num).toInt(),
  hranaIPiceId: (json['hranaIpićeId'] as num).toInt(),
  hranaIPice:
      json['hranaIpiće'] == null
          ? null
          : HranaPice.fromJson(json['hranaIpiće'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RezervacijaHranaPiceToJson(
  RezervacijaHranaPice instance,
) => <String, dynamic>{
  'rezervacijaId': instance.rezervacijaId,
  'hranaIpićeId': instance.hranaIPiceId,
  'hranaIpiće': instance.hranaIPice,
};
