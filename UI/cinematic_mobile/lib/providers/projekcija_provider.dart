import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class ProjekcijaProvider extends BaseProvider<Projekcija> {
  ProjekcijaProvider() : super("Projekcije");

  @override
  Projekcija fromJson(data) => Projekcija.fromJson(data);
}