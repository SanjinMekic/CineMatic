// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sala.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sala _$SalaFromJson(Map<String, dynamic> json) =>
    Sala(id: (json['id'] as num).toInt(), naziv: json['naziv'] as String?);

Map<String, dynamic> _$SalaToJson(Sala instance) => <String, dynamic>{
  'id': instance.id,
  'naziv': instance.naziv,
};
