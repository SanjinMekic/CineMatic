import 'package:json_annotation/json_annotation.dart';

part 'rezervacija_film_dto.g.dart';

@JsonSerializable()
class RezervacijaFilmDTO {
  int? rezervacijaId;
  DateTime? datumRezervacije;
  String? nacinPlacanja;
  int? projekcijaId;
  DateTime? datumProjekcije;
  List<int>? sjedistaIds;
  List<int>? hranaPiceIds;
  List<int>? kolicine;
  double? ukupnaCijena;
  String? qrCodeBase64;
  int? filmId;
  String? nazivFilma;
  int? trajanjeFilma;
  String? opis;
  String? filmaSlikaBase64;

  RezervacijaFilmDTO({
    this.rezervacijaId,
    this.datumRezervacije,
    this.nacinPlacanja,
    this.projekcijaId,
    this.datumProjekcije,
    this.sjedistaIds,
    this.hranaPiceIds,
    this.filmId,
    this.nazivFilma,
    this.trajanjeFilma,
    this.opis,
    this.filmaSlikaBase64,
  });

  factory RezervacijaFilmDTO.fromJson(Map<String, dynamic> json) =>
      _$RezervacijaFilmDTOFromJson(json);

  Map<String, dynamic> toJson() => _$RezervacijaFilmDTOToJson(this);
}