import 'package:cinematic_desktop/models/film.dart';
import 'package:cinematic_desktop/models/nacin_prikazivanja.dart';
import 'package:cinematic_desktop/models/sala.dart';
import 'package:json_annotation/json_annotation.dart';

part 'projekcija.g.dart';

@JsonSerializable(explicitToJson: true)
class Projekcija {
  int? id;
  int? filmId;
  int? salaId;
  @JsonKey(name: 'načinProjekcijeId')
  int? nacinProjekcijeId;
  DateTime? datumIvrijeme;
  double? cijena;
  String? stanje;
  Film? film;
  @JsonKey(name: 'načinProjekcije')
  NacinPrikazivanja? nacinProjekcije;
  Sala? sala;

  Projekcija({
    this.id,
    this.filmId,
    this.salaId,
    this.nacinProjekcijeId,
    this.datumIvrijeme,
    this.cijena,
    this.stanje,
    this.film,
    this.nacinProjekcije,
    this.sala,
  });

  factory Projekcija.fromJson(Map<String, dynamic> json) => _$ProjekcijaFromJson(json);
  Map<String, dynamic> toJson() => _$ProjekcijaToJson(this);
}