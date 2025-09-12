import 'package:cinematic_mobile/models/dobna_restrikcija.dart';
import 'package:cinematic_mobile/models/glumac.dart';
import 'package:cinematic_mobile/models/reziser.dart';
import 'package:cinematic_mobile/models/zanr.dart';
import 'package:json_annotation/json_annotation.dart';

part 'film.g.dart';

@JsonSerializable(explicitToJson: true)
class Film {
  int? id;
  String? naziv;
  int? trajanje;
  String? opis;
  String? slikaBase64;
  int? dobnaRestrikcijaId;
  DobnaRestrikcija? dobnaRestrikcija;
  List<Glumac>? glumacs;

  @JsonKey(name: 'režisers')
  List<Reziser>? rezisers;

  @JsonKey(name: 'žanrs')
  List<Zanr>? zanrs;

  Film({
    this.id,
    this.naziv,
    this.trajanje,
    this.opis,
    this.slikaBase64,
    this.dobnaRestrikcijaId,
    this.dobnaRestrikcija,
    this.glumacs,
    this.rezisers,
    this.zanrs,
  });

  factory Film.fromJson(Map<String, dynamic> json) => _$FilmFromJson(json);
  Map<String, dynamic> toJson() => _$FilmToJson(this);
}