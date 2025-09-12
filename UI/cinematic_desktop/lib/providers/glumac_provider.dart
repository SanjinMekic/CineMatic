import 'package:cinematic_desktop/models/glumac.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class GlumacProvider extends BaseProvider<Glumac> {
  GlumacProvider() : super("Glumci");

  @override
  Glumac fromJson(data) {
    return Glumac.fromJson(data);
  }
}