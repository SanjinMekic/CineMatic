import 'dart:convert';
import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/models/sjediste_dto.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class ProjekcijaProvider extends BaseProvider<Projekcija> {
  ProjekcijaProvider() : super("Projekcije");

  @override
  Projekcija fromJson(data) => Projekcija.fromJson(data);

  /// Dohvati projekcije za filmId preko /Projekcije/PoFilmu/{filmId}
  Future<List<Projekcija>> getByFilm(int filmId) async {
    final url = Uri.parse('$baseUrl${endpoint}/PoFilmu/$filmId');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Projekcija.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu projekcija za film');
    }
  }

   Future<List<SjedisteDTO>> getSjedista(int projekcijaId) async {
    final url = Uri.parse('$baseUrl${endpoint}/Sjedista/$projekcijaId');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SjedisteDTO.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu sjedišta za projekciju');
    }
  }
}