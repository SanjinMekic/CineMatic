import 'package:cinematic_desktop/models/projekcija.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class ProjekcijaProvider extends BaseProvider<Projekcija> {
  ProjekcijaProvider() : super("Projekcije");

  @override
  Projekcija fromJson(data) => Projekcija.fromJson(data);
}