import 'package:json_annotation/json_annotation.dart';
import 'kategorija_hrane_pica.dart';

part 'hrana_pice.g.dart';

@JsonSerializable()
class HranaPice {
  int id;
  int? kategorijaId;
  String? naziv;
  double? cijena;
  String? opis;
  @JsonKey(name: 'količinaUskladištu')
  int? kolicinaUskladistu;
  String? slikaBase64;
  KategorijaHranePica? kategorija;

  HranaPice({
    required this.id,
    this.kategorijaId,
    this.naziv,
    this.cijena,
    this.opis,
    this.kolicinaUskladistu,
    this.slikaBase64,
    this.kategorija,
  });

  factory HranaPice.fromJson(Map<String, dynamic> json) =>
      _$HranaPiceFromJson(json);

  Map<String, dynamic> toJson() => _$HranaPiceToJson(this);
}