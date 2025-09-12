// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Faq _$FaqFromJson(Map<String, dynamic> json) => Faq(
  id: (json['id'] as num).toInt(),
  kategorijaId: (json['kategorijaId'] as num?)?.toInt(),
  pitanje: json['pitanje'] as String?,
  odgovor: json['odgovor'] as String?,
  kategorija:
      json['kategorija'] == null
          ? null
          : FaqKategorija.fromJson(json['kategorija'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FaqToJson(Faq instance) => <String, dynamic>{
  'id': instance.id,
  'kategorijaId': instance.kategorijaId,
  'pitanje': instance.pitanje,
  'odgovor': instance.odgovor,
  'kategorija': instance.kategorija,
};
