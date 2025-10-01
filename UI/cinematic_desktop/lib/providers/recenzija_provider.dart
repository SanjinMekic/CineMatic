import 'dart:convert';
import 'package:cinematic_desktop/models/recenzija.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RecenzijaProvider extends BaseProvider<Recenzija> {
  RecenzijaProvider() : super("Recenzije");

  @override
  Recenzija fromJson(data) => Recenzija.fromJson(data);

  Future<List<Recenzija>> getByFilm(int filmId) async {
    final url = Uri.parse('$baseUrl${endpoint}/ByFilm/$filmId');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Recenzija.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu recenzija za film');
    }
  }

  Future<List<Recenzija>> getByFilmAndRating(int filmId, int? ocjena) async {
    final query = ocjena != null ? '?ocjena=$ocjena' : '';
    final url = Uri.parse('$baseUrl${endpoint}/ByFilmAndRating/$filmId$query');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Recenzija.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu recenzija po ocjeni');
    }
  }

  Future<double> getAverageRating(int filmId) async {
    final url = Uri.parse('$baseUrl${endpoint}/prosjecnaOcjena/$filmId');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['ocjena'] as num?)?.toDouble() ?? 0.0;
    } else {
      throw Exception('Greška pri dohvatu prosječne ocjene za film');
    }
  }
}