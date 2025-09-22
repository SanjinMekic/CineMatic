import 'package:cinematic_mobile/models/korisnik.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnici");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }

  Future<bool> korisnickoImeZauzeto(String korisnickoIme) async {
    final result = await get();
    for (var korisnik in result.result) {
      if (korisnik.korisnickoIme?.toLowerCase() == korisnickoIme.toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}