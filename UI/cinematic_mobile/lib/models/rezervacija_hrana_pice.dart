import 'package:cinematic_mobile/models/hrana_pice.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rezervacija_hrana_pice.g.dart';

@JsonSerializable()
class RezervacijaHranaPice {
  int rezervacijaId;
  @JsonKey(name: 'hranaIpićeId')
  int hranaIPiceId;
  @JsonKey(name: 'hranaIpiće')
  HranaPice? hranaIPice;

  RezervacijaHranaPice({
    required this.rezervacijaId,
    required this.hranaIPiceId,
    this.hranaIPice,
  });

  factory RezervacijaHranaPice.fromJson(Map<String, dynamic> json) => _$RezervacijaHranaPiceFromJson(json);
  Map<String, dynamic> toJson() => _$RezervacijaHranaPiceToJson(this);
}