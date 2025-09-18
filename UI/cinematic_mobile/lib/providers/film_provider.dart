import 'dart:convert';

import 'package:cinematic_mobile/models/film.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';
import 'package:cinematic_mobile/models/preporuceni_film.dart';
import 'package:http/http.dart' as http;

class FilmProvider extends BaseProvider<Film> {
  FilmProvider() : super("Filmovi");

  @override
  Film fromJson(data) => Film.fromJson(data);

  Future<List<PreporuceniFilm>> getRecommendations(int filmId) async {
    final url = Uri.parse('${baseUrl}Filmovi/$filmId/recommendations');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PreporuceniFilm.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu preporuka');
    }
  }
}
