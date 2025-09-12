import 'package:cinematic_desktop/models/film.dart';
import 'package:cinematic_desktop/models/korisnik.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recenzija.g.dart';

@JsonSerializable(explicitToJson: true)
class Recenzija {
  int? id;
  int? korisnikId;
  int? filmId;
  int? ocjena;
  DateTime? datumIvrijeme;
  String? komentar;
  Film? film;
  Korisnik? korisnik;

  Recenzija({
    this.id,
    this.korisnikId,
    this.filmId,
    this.ocjena,
    this.datumIvrijeme,
    this.komentar,
    this.film,
    this.korisnik,
  });

  factory Recenzija.fromJson(Map<String, dynamic> json) => _$RecenzijaFromJson(json);
  Map<String, dynamic> toJson() => _$RecenzijaToJson(this);
}