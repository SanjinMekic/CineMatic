// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_kategorija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqKategorija _$FaqKategorijaFromJson(Map<String, dynamic> json) =>
    FaqKategorija(
      id: (json['id'] as num).toInt(),
      naziv: json['naziv'] as String?,
    );

Map<String, dynamic> _$FaqKategorijaToJson(FaqKategorija instance) =>
    <String, dynamic>{'id': instance.id, 'naziv': instance.naziv};
