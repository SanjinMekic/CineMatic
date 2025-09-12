import 'package:json_annotation/json_annotation.dart';
import 'faq_kategorija.dart';

part 'faq.g.dart';

@JsonSerializable()
class Faq {
  int id;
  int? kategorijaId;
  String? pitanje;
  String? odgovor;
  FaqKategorija? kategorija;

  Faq({
    required this.id,
    this.kategorijaId,
    this.pitanje,
    this.odgovor,
    this.kategorija,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => _$FaqFromJson(json);

  Map<String, dynamic> toJson() => _$FaqToJson(this);
}