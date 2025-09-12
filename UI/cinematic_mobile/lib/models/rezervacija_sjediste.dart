import 'package:cinematic_mobile/models/sjediste.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rezervacija_sjediste.g.dart';

@JsonSerializable()
class RezervacijaSjediste {
  int rezervacijaId;
  @JsonKey(name: 'sjedišteId')
  int sjedisteId;
  @JsonKey(name: 'sjedište')
  Sjediste? sjediste;

  RezervacijaSjediste({
    required this.rezervacijaId,
    required this.sjedisteId,
    this.sjediste,
  });

  factory RezervacijaSjediste.fromJson(Map<String, dynamic> json) => _$RezervacijaSjedisteFromJson(json);
  Map<String, dynamic> toJson() => _$RezervacijaSjedisteToJson(this);
}