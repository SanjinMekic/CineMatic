// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rezervacija _$RezervacijaFromJson(Map<String, dynamic> json) => Rezervacija(
  id: (json['id'] as num).toInt(),
  korisnikId: (json['korisnikId'] as num?)?.toInt(),
  projekcijaId: (json['projekcijaId'] as num?)?.toInt(),
  uplataId: (json['uplataId'] as num?)?.toInt(),
  datumIvrijeme:
      json['datumIvrijeme'] == null
          ? null
          : DateTime.parse(json['datumIvrijeme'] as String),
  brojUlaznica: (json['brojUlaznica'] as num?)?.toInt(),
  ukupnaCijena: (json['ukupnaCijena'] as num?)?.toDouble(),
  nacinPlacanja: json['načinPlaćanja'] as String?,
  qrcodeBase64: json['qrcodeBase64'] as String?,
  korisnik:
      json['korisnik'] == null
          ? null
          : Korisnik.fromJson(json['korisnik'] as Map<String, dynamic>),
  projekcija:
      json['projekcija'] == null
          ? null
          : Projekcija.fromJson(json['projekcija'] as Map<String, dynamic>),
  rezervacijeSjedista:
      (json['rezervacijeSjedišta'] as List<dynamic>?)
          ?.map((e) => RezervacijaSjediste.fromJson(e as Map<String, dynamic>))
          .toList(),
  rezervacijeHraneIPica:
      (json['rezervacijeHraneIpićas'] as List<dynamic>?)
          ?.map((e) => RezervacijaHranaPice.fromJson(e as Map<String, dynamic>))
          .toList(),
  uplata:
      json['uplata'] == null
          ? null
          : Uplata.fromJson(json['uplata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RezervacijaToJson(Rezervacija instance) =>
    <String, dynamic>{
      'id': instance.id,
      'korisnikId': instance.korisnikId,
      'projekcijaId': instance.projekcijaId,
      'uplataId': instance.uplataId,
      'datumIvrijeme': instance.datumIvrijeme?.toIso8601String(),
      'brojUlaznica': instance.brojUlaznica,
      'ukupnaCijena': instance.ukupnaCijena,
      'načinPlaćanja': instance.nacinPlacanja,
      'qrcodeBase64': instance.qrcodeBase64,
      'korisnik': instance.korisnik?.toJson(),
      'projekcija': instance.projekcija?.toJson(),
      'rezervacijeSjedišta':
          instance.rezervacijeSjedista?.map((e) => e.toJson()).toList(),
      'rezervacijeHraneIpićas':
          instance.rezervacijeHraneIPica?.map((e) => e.toJson()).toList(),
      'uplata': instance.uplata?.toJson(),
    };
