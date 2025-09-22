import 'package:cinematic_desktop/models/korisnik.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnici");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }

  Future<String> aktivirajObrisanogKorisnika(int id) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/aktiviraj');
    final headers = createHeaders();
    final response = await http.put(url, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 404) {
      throw Exception('Korisnik nije pronađen.');
    } else {
      throw Exception('Greška pri aktivaciji korisnika.');
    }
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