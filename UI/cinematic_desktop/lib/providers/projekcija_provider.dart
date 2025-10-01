import 'dart:convert';

import 'package:cinematic_desktop/models/projekcija.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class ProjekcijaProvider extends BaseProvider<Projekcija> {
  ProjekcijaProvider() : super("Projekcije");

  @override
  Projekcija fromJson(data) => Projekcija.fromJson(data);

   Future<List<Projekcija>> getAllProjekcije() async {
    final result = await get();
    return result.result;
  }

  Future<bool> hasActiveForSala(int salaId) async {
    final projekcije = await getAllProjekcije();
    return projekcije.any((p) => p.salaId == salaId && p.stanje == "active");
  }

  Future<bool> hasActiveForNacinPrikazivanja(int nacinId) async {
    final projekcije = await getAllProjekcije();
    return projekcije.any((p) => p.nacinProjekcijeId == nacinId && p.stanje == "active");
  }

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
}