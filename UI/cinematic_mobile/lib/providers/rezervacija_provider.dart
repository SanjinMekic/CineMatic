import 'dart:convert';

import 'package:cinematic_mobile/models/rezervacija.dart';
import 'package:cinematic_mobile/models/rezervacija_film_dto.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';
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

  Future<List<RezervacijaFilmDTO>> getRezervacijeKorisnika(int korisnikId) async {
    final url = Uri.parse('$baseUrl${endpoint}/projekcijaKorisnik/$korisnikId');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RezervacijaFilmDTO.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu rezervacija');
    }
  }

    Future<void> ponistiKartu(int rezervacijaId) async {
  final url = Uri.parse('$baseUrl${endpoint}/ponisti/$rezervacijaId');
  final headers = createHeaders();

  final response = await http.put(url, headers: headers);

  if (response.statusCode == 200) {
    return;
  } else {
    String message;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('Message')) {
        message = decoded['Message'];
        if (message.contains('Rezervacija nije pronađena')) {
          message = 'Rezervacija nije pronađena!';
        } else if (message.contains('Karta je već poništena')) {
          message = 'Karta je već poništena!';
        }
      } else {
        message = response.body.toString();
      }
    } catch (_) {
      message = response.body.toString();
    }
    throw Exception(message);
  }
}
}