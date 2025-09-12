import 'package:cinematic_desktop/models/zanr.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class ZanrProvider extends BaseProvider<Zanr> {
  ZanrProvider() : super("Žanrovi");

  @override
  Zanr fromJson(data) {
    // TODO: implement fromJson
    return Zanr.fromJson(data);
  }
}
