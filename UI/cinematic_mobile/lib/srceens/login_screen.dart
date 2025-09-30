import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:cinematic_mobile/layouts/master_screen.dart';
import 'package:cinematic_mobile/models/korisnik.dart';
import 'package:cinematic_mobile/srceens/registracija_screen.dart';
import 'package:cinematic_mobile/srceens/ponistavanje_karti_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _passwordError;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _passwordError = null;
      _isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;
    final authProvider = AuthProvider();

    try {
      final response = await authProvider.login(username, password);

      if (response == null) {
        setState(() {
          _passwordError = "Pogrešno korisničko ime ili lozinka";
        });
      } else {
        AuthProvider.username = username;
        AuthProvider.password = password;
        AuthProvider.setUser(response);

        if (_isBlagajnik(response)) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PonistavanjeKartiScreen(),
            ),
          );
        } else if (_isKorisnik(response)) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MasterScreen(),
            ),
          );
        } else {
          setState(() {
            _passwordError = "Nemate prava";
          });
        }
      }
    } on Exception catch (e) {
      setState(() {
        _passwordError = e.toString().contains("Unauthorized")
            ? "Pogrešno korisničko ime ili lozinka."
            : e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isBlagajnik(Korisnik user) {
    final roles = user.ulogas;
    return roles != null && roles.any((role) => role.naziv!.toLowerCase() == 'blagajnik');
  }

  bool _isKorisnik(Korisnik user) {
    final roles = user.ulogas;
    return roles != null && roles.any((role) => role.naziv!.toLowerCase() == 'korisnik');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/CineMaticPNG.png'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Dobrodošli!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Prijavite se na svoj CineMatic nalog",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: "Korisničko ime",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Unesite korisničko ime" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            labelText: "Lozinka",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value == null || value.isEmpty ? "Unesite lozinku" : null,
                        ),
                        if (_passwordError != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _passwordError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 28),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.login, color: Colors.white),
                                  label: const Text("Prijavi se"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                                ),
                              ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Nemate račun?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegistracijaScreen()),
                                );
                              },
                              child: const Text(
                                "Kreirajte ga!",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}