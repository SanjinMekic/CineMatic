import 'package:json_annotation/json_annotation.dart';

part 'dobna_restrikcija.g.dart';

@JsonSerializable()
class DobnaRestrikcija {
  int id;
  String? restrikcija;
  String? opis;

  DobnaRestrikcija({required this.id, this.restrikcija, this.opis});

  factory DobnaRestrikcija.fromJson(Map<String, dynamic> json) => _$DobnaRestrikcijaFromJson(json);
  Map<String, dynamic> toJson() => _$DobnaRestrikcijaToJson(this);
}