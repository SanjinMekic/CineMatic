import 'package:cinematic_desktop/models/dobna_restrikcija.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class DobnaRestrikcijaProvider extends BaseProvider<DobnaRestrikcija> {
  DobnaRestrikcijaProvider() : super("DobneRestrikcije");

  @override
  DobnaRestrikcija fromJson(data) => DobnaRestrikcija.fromJson(data);
}