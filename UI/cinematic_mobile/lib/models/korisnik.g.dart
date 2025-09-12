// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korisnik _$KorisnikFromJson(Map<String, dynamic> json) => Korisnik(
  id: (json['id'] as num).toInt(),
  ime: json['ime'] as String?,
  prezime: json['prezime'] as String?,
  korisnickoIme: json['korisnickoIme'] as String?,
  email: json['email'] as String?,
  slikaBase64: json['slikaBase64'] as String?,
  ulogas:
      (json['ulogas'] as List<dynamic>?)
          ?.map((e) => Uloga.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$KorisnikToJson(Korisnik instance) => <String, dynamic>{
  'id': instance.id,
  'ime': instance.ime,
  'prezime': instance.prezime,
  'korisnickoIme': instance.korisnickoIme,
  'email': instance.email,
  'slikaBase64': instance.slikaBase64,
  'ulogas': instance.ulogas,
};
