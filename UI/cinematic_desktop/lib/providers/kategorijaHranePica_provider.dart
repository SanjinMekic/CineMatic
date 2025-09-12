import 'package:cinematic_desktop/models/kategorija_hrane_pica.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class KategorijaHranePicaProvider extends BaseProvider<KategorijaHranePica> {
  KategorijaHranePicaProvider() : super("KategorijeHraneIpića");

  @override
  KategorijaHranePica fromJson(data) {
    return KategorijaHranePica.fromJson(data);
  }
}