import 'package:json_annotation/json_annotation.dart';

part 'reziser.g.dart';

@JsonSerializable()
class Reziser {
  int id;
  String? ime;
  String? prezime;
  DateTime? datumRodjenja;
  String? opis;
  String? slikaBase64;

  Reziser({
    required this.id,
    this.ime,
    this.prezime,
    this.datumRodjenja,
    this.opis,
    this.slikaBase64,
  });

  factory Reziser.fromJson(Map<String, dynamic> json) => _$ReziserFromJson(json);

  Map<String, dynamic> toJson() => _$ReziserToJson(this);
}