import 'package:json_annotation/json_annotation.dart';

part 'sjediste.g.dart';

@JsonSerializable()
class Sjediste {
  int id;
  String? naziv;

  Sjediste({required this.id, this.naziv});

  factory Sjediste.fromJson(Map<String, dynamic> json) => _$SjedisteFromJson(json);
  Map<String, dynamic> toJson() => _$SjedisteToJson(this);
}