import 'dart:convert';
import 'package:cinematic_desktop/models/broj_sjedista_po_filmu.dart';
import 'package:cinematic_desktop/models/top_korisnik.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class IzvjestajiProvider extends BaseProvider<dynamic> {
  IzvjestajiProvider() : super("Izvjestaji");

  Future<int> getBrojKorisnika() async {
    final url = Uri.parse('${baseUrl}Izvjestaji/brojKorisnika');
    final response = await http.get(url, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['userCount'] ?? data['UserCount'] ?? 0;
    } else {
      throw Exception('Greška pri dohvatu broja korisnika');
    }
  }

   Future<int> getBrojAdmina() async {
    final url = Uri.parse('${baseUrl}Izvjestaji/brojAdmina');
    final response = await http.get(url, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['adminCount'] ?? data['AdminCount'] ?? 0;
    } else {
      throw Exception('Greška pri dohvatu broja administratora');
    }
  }

  Future<int> getBrojBlagajnika() async {
    final url = Uri.parse('${baseUrl}Izvjestaji/brojBlagajnika');
    final response = await http.get(url, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['blagajnikCount'] ?? data['BlagajnikCount'] ?? 0;
    } else {
      throw Exception('Greška pri dohvatu broja administratora');
    }
  }

  Future<double> getUkupnaZarada() async {
    final url = Uri.parse('${baseUrl}Izvjestaji/ukupnaZarada');
    final response = await http.get(url, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['totalIncome'] ?? data['TotalIncome'] ?? 0).toDouble();
    } else {
      throw Exception('Greška pri dohvatu ukupne zarade');
    }
  }

  Future<double> getUkupnaZaradaHranaPice() async {
    final url = Uri.parse('${baseUrl}Izvjestaji/ukupnaZaradaHranaPice');
    final response = await http.get(url, headers: createHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['totalFoodDrinkIncome'] ?? data['TotalFoodDrinkIncome'] ?? 0).toDouble();
    } else {
      throw Exception('Greška pri dohvatu zarade od hrane i pića');
    }
  }

  Future<List<TopKorisnik>> getTop5Korisnika() async {
  final url = Uri.parse('${baseUrl}Izvjestaji/top5korisnika');
  final response = await http.get(url, headers: createHeaders());
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => TopKorisnik.fromJson(e)).toList();
  } else {
    throw Exception('Greška pri dohvatu top 5 korisnika');
  }
}

  Future<List<BrojSjedistaPoFilmu>> getTop5NajgledanijihFilmova() async {
  final url = Uri.parse('${baseUrl}Izvjestaji/top5najgledanijihFilmova');
  final response = await http.get(url, headers: createHeaders());
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => BrojSjedistaPoFilmu.fromJson(e)).toList();
  } else {
    throw Exception('Greška pri dohvatu top 5 filmova');
  }
}
}