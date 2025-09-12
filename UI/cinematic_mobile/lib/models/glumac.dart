import 'package:json_annotation/json_annotation.dart';

part 'glumac.g.dart';

@JsonSerializable()
class Glumac {
  int id;
  String? ime;
  String? prezime;
  DateTime? datumRodjenja;
  String? opis;
  String? slikaBase64;

  Glumac({
    required this.id,
    this.ime,
    this.prezime,
    this.datumRodjenja,
    this.opis,
    this.slikaBase64,
  });

  factory Glumac.fromJson(Map<String, dynamic> json) => _$GlumacFromJson(json);

  Map<String, dynamic> toJson() => _$GlumacToJson(this);
}