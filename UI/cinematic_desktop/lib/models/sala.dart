import 'package:json_annotation/json_annotation.dart';

part 'sala.g.dart';

@JsonSerializable()
class Sala {
  int id;
  String? naziv;

  Sala({required this.id, this.naziv});

  factory Sala.fromJson(Map<String, dynamic> json) => _$SalaFromJson(json);
  Map<String, dynamic> toJson() => _$SalaToJson(this);
}