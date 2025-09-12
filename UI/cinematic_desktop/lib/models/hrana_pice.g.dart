// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hrana_pice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HranaPice _$HranaPiceFromJson(Map<String, dynamic> json) => HranaPice(
  id: (json['id'] as num).toInt(),
  kategorijaId: (json['kategorijaId'] as num?)?.toInt(),
  naziv: json['naziv'] as String?,
  cijena: (json['cijena'] as num?)?.toDouble(),
  opis: json['opis'] as String?,
  kolicinaUskladistu: (json['količinaUskladištu'] as num?)?.toInt(),
  slikaBase64: json['slikaBase64'] as String?,
  kategorija:
      json['kategorija'] == null
          ? null
          : KategorijaHranePica.fromJson(
            json['kategorija'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$HranaPiceToJson(HranaPice instance) => <String, dynamic>{
  'id': instance.id,
  'kategorijaId': instance.kategorijaId,
  'naziv': instance.naziv,
  'cijena': instance.cijena,
  'opis': instance.opis,
  'količinaUskladištu': instance.kolicinaUskladistu,
  'slikaBase64': instance.slikaBase64,
  'kategorija': instance.kategorija,
};
