import 'package:cinematic_mobile/models/uloga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'korisnik.g.dart';

@JsonSerializable()
class Korisnik {
  int id;
  String? ime;
  String? prezime;
  String? korisnickoIme;
  String? email;
  String? slikaBase64;
  List<Uloga>? ulogas;
  bool? obrisan;

  Korisnik({
    required this.id,
    this.ime,
    this.prezime,
    this.korisnickoIme,
    this.email,
    this.slikaBase64,
    this.ulogas,
    this.obrisan,
  });

  factory Korisnik.fromJson(Map<String, dynamic> json) =>
      _$KorisnikFromJson(json);

  Map<String, dynamic> toJson() => _$KorisnikToJson(this);
}