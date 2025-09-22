import 'package:json_annotation/json_annotation.dart';
import 'korisnik.dart';
import 'projekcija.dart';
import 'rezervacija_sjediste.dart';
import 'rezervacija_hrana_pice.dart';
import 'uplata.dart';

part 'rezervacija.g.dart';

@JsonSerializable(explicitToJson: true)
class Rezervacija {
  int id;
  int? korisnikId;
  int? projekcijaId;
  int? uplataId;
  DateTime? datumIvrijeme;
  int? brojUlaznica;
  double? ukupnaCijena;
  @JsonKey(name: 'načinPlaćanja')
  String? nacinPlacanja;
  String? qrcodeBase64;
  Korisnik? korisnik;
  Projekcija? projekcija;
  @JsonKey(name: 'rezervacijeSjedišta')
  List<RezervacijaSjediste>? rezervacijeSjedista;
  @JsonKey(name: 'rezervacijeHraneIpićas')
  List<RezervacijaHranaPice>? rezervacijeHraneIPica;
  Uplata? uplata;
  bool? ponistenaKarta;

  Rezervacija({
    required this.id,
    this.korisnikId,
    this.projekcijaId,
    this.uplataId,
    this.datumIvrijeme,
    this.brojUlaznica,
    this.ukupnaCijena,
    this.nacinPlacanja,
    this.qrcodeBase64,
    this.korisnik,
    this.projekcija,
    this.rezervacijeSjedista,
    this.rezervacijeHraneIPica,
    this.uplata,
    this.ponistenaKarta
  });

     
  factory Rezervacija.fromJson(Map<String, dynamic> json) => _$RezervacijaFromJson(json);
 
 Map<String, dynamic> toJson() => _$RezervacijaToJson(this);
}