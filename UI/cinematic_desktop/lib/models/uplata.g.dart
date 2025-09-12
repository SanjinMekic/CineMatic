// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uplata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Uplata _$UplataFromJson(Map<String, dynamic> json) => Uplata(
  id: (json['id'] as num).toInt(),
  izdavac: json['izdavač'] as String?,
  transakcijaId: json['transakcijaId'] as String?,
  iznos: (json['iznos'] as num?)?.toDouble(),
  datumIvrijeme:
      json['datumIvrijeme'] == null
          ? null
          : DateTime.parse(json['datumIvrijeme'] as String),
);

Map<String, dynamic> _$UplataToJson(Uplata instance) => <String, dynamic>{
  'id': instance.id,
  'izdavač': instance.izdavac,
  'transakcijaId': instance.transakcijaId,
  'iznos': instance.iznos,
  'datumIvrijeme': instance.datumIvrijeme?.toIso8601String(),
};
