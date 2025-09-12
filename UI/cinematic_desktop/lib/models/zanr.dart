import 'package:json_annotation/json_annotation.dart';

part 'zanr.g.dart';

@JsonSerializable()
class Zanr {
  int? id;
  String? naziv;

  Zanr({
    this.id,
    this.naziv,
  });

   factory Zanr.fromJson(Map<String, dynamic> json) =>
      _$ZanrFromJson(json);

    Map<String, dynamic> toJson() => _$ZanrToJson(this);
}
