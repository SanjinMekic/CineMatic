import 'package:json_annotation/json_annotation.dart';

part 'kategorija_hrane_pica.g.dart';

@JsonSerializable()
class KategorijaHranePica {
  int id;
  String naziv;

  KategorijaHranePica({
    required this.id,
    required this.naziv,
  });

  factory KategorijaHranePica.fromJson(Map<String, dynamic> json) =>
      _$KategorijaHranePicaFromJson(json);

  Map<String, dynamic> toJson() => _$KategorijaHranePicaToJson(this);
}