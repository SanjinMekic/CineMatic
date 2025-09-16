import 'dart:convert';

import 'package:cinematic_mobile/models/korisnik.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends BaseProvider<Korisnik> {
  AuthProvider() : super("Korisnici");

  static String? username;
  static String? password;
  static int? korisnikId;

  static void setUser(Korisnik korisnik) {
    korisnikId = korisnik.id;
  }

  Future<Korisnik?> login(String username, String password) async {
    print('Pozivam login metodu');
    try {
      final url = Uri.parse("${baseUrl}Korisnici/login");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Login response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final user = Korisnik.fromJson(jsonDecode(response.body));
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
