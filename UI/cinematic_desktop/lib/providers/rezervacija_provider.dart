import 'dart:convert';

import 'package:cinematic_desktop/models/rezervacija.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacije");

  @override
  Rezervacija fromJson(data) => Rezervacija.fromJson(data);

  Future<List<Rezervacija>> getByProjekcija(int projekcijaId) async {
    final url = Uri.parse('$baseUrl${endpoint}/projekcija/$projekcijaId');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Rezervacija.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu rezervacija');
    }
  }
}