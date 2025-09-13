import 'package:cinematic_mobile/models/zanr.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class ZanrProvider extends BaseProvider<Zanr> {
  ZanrProvider() : super("Žanrovi");

  @override
  Zanr fromJson(data) {
    // TODO: implement fromJson
    return Zanr.fromJson(data);
  }
}
