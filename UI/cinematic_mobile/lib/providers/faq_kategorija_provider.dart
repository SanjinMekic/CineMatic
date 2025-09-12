import 'package:cinematic_mobile/models/faq_kategorija.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class FaqKategorijaProvider extends BaseProvider<FaqKategorija> {
  FaqKategorijaProvider() : super("FAQKategorije");

  @override
  FaqKategorija fromJson(data) {
    return FaqKategorija.fromJson(data);
  }
}