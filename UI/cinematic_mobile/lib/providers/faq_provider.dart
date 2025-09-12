import 'package:cinematic_mobile/models/faq.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class FaqProvider extends BaseProvider<Faq> {
  FaqProvider() : super("FAQs");

  @override
  Faq fromJson(data) {
    return Faq.fromJson(data);
  }
}