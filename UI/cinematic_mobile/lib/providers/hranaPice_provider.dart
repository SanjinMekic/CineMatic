import 'package:cinematic_mobile/models/hrana_pice.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class HranaPiceProvider extends BaseProvider<HranaPice> {
  HranaPiceProvider() : super("HraneIpića");

  @override
  HranaPice fromJson(data) {
    return HranaPice.fromJson(data);
  }
}