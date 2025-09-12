import 'package:cinematic_desktop/models/nacin_prikazivanja.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class NacinPrikazivanjaProvider extends BaseProvider<NacinPrikazivanja> {
  NacinPrikazivanjaProvider() : super("NačiniPrikazivanja");

  @override
  NacinPrikazivanja fromJson(data) => NacinPrikazivanja.fromJson(data);
}