import 'package:json_annotation/json_annotation.dart';

part 'preporuceni_film.g.dart';

@JsonSerializable()
class PreporuceniFilm {
  int id;
  String naslov;
  List<String> zanrovi;
  List<String> glumci;
  String? imageBase64;

  PreporuceniFilm({
    required this.id,
    required this.naslov,
    required this.zanrovi,
    required this.glumci,
    this.imageBase64,
  });

  factory PreporuceniFilm.fromJson(Map<String, dynamic> json) => _$PreporuceniFilmFromJson(json);
  Map<String, dynamic> toJson() => _$PreporuceniFilmToJson(this);
}