import 'package:cinematic_desktop/models/hrana_pice.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class HranaPiceProvider extends BaseProvider<HranaPice> {
  HranaPiceProvider() : super("HraneIpića");

  @override
  HranaPice fromJson(data) {
    return HranaPice.fromJson(data);
  }
}