import 'package:cinematic_mobile/models/reziser.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class ReziserProvider extends BaseProvider<Reziser> {
  ReziserProvider() : super("Režiseri");

  @override
  Reziser fromJson(data) {
    return Reziser.fromJson(data);
  }
}