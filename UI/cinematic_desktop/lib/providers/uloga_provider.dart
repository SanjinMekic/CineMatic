import 'package:cinematic_desktop/models/uloga.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class UlogaProvider extends BaseProvider<Uloga> {
  UlogaProvider() : super("Uloge");

  @override
  Uloga fromJson(data) {
    return Uloga.fromJson(data);
  }
}