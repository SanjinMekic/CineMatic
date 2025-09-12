import 'package:json_annotation/json_annotation.dart';

part 'nacin_prikazivanja.g.dart';

@JsonSerializable()
class NacinPrikazivanja {
  int id;
  String? naziv;

  NacinPrikazivanja({required this.id, this.naziv});

  factory NacinPrikazivanja.fromJson(Map<String, dynamic> json) => _$NacinPrikazivanjaFromJson(json);
  Map<String, dynamic> toJson() => _$NacinPrikazivanjaToJson(this);
}