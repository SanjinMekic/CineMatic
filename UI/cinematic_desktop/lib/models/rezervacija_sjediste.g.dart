// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija_sjediste.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RezervacijaSjediste _$RezervacijaSjedisteFromJson(Map<String, dynamic> json) =>
    RezervacijaSjediste(
      rezervacijaId: (json['rezervacijaId'] as num).toInt(),
      sjedisteId: (json['sjedišteId'] as num).toInt(),
      sjediste:
          json['sjedište'] == null
              ? null
              : Sjediste.fromJson(json['sjedište'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RezervacijaSjedisteToJson(
  RezervacijaSjediste instance,
) => <String, dynamic>{
  'rezervacijaId': instance.rezervacijaId,
  'sjedišteId': instance.sjedisteId,
  'sjedište': instance.sjediste,
};
