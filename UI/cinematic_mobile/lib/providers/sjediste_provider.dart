import 'package:cinematic_mobile/models/sjediste.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class SjedisteProvider extends BaseProvider<Sjediste> {
  SjedisteProvider() : super("Sjedištum");

  @override
  Sjediste fromJson(data) => Sjediste.fromJson(data);
}