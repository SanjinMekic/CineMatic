import 'package:json_annotation/json_annotation.dart';

part 'uplata.g.dart';

@JsonSerializable()
class Uplata {
  int id;
  @JsonKey(name: 'izdavač')
  String? izdavac;
  String? transakcijaId;
  double? iznos;
  DateTime? datumIvrijeme;

  Uplata({
    required this.id,
    this.izdavac,
    this.transakcijaId,
    this.iznos,
    this.datumIvrijeme,
  });

  factory Uplata.fromJson(Map<String, dynamic> json) => _$UplataFromJson(json);
  Map<String, dynamic> toJson() => _$UplataToJson(this);
}