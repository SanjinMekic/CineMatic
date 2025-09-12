import 'package:cinematic_desktop/models/sala.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class SalaProvider extends BaseProvider<Sala> {
  SalaProvider() : super("Sale");

  @override
  Sala fromJson(data) => Sala.fromJson(data);
}