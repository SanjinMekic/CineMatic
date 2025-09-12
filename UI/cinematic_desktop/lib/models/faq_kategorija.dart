import 'package:json_annotation/json_annotation.dart';

part 'faq_kategorija.g.dart';

@JsonSerializable()
class FaqKategorija {
  int id;
  String? naziv;

  FaqKategorija({
    required this.id,
    this.naziv,
  });

  factory FaqKategorija.fromJson(Map<String, dynamic> json) => _$FaqKategorijaFromJson(json);

  Map<String, dynamic> toJson() => _$FaqKategorijaToJson(this);
}