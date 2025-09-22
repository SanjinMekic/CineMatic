import 'package:cinematic_desktop/providers/auth_provider.dart';
import 'package:cinematic_desktop/layouts/master_screen.dart';
import 'package:cinematic_desktop/models/korisnik.dart';
import 'package:cinematic_desktop/screens/pocetna_screen.dart';
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
          _passwordError = "Pogresno korisničko ime ili password";
        });
      } else {
        AuthProvider.username = username;
        AuthProvider.password = password;
        AuthProvider.setUser(response);

        if (_isAdmin(response)) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MasterScreen(
                "Početna",
                PocetnaScreen(),
              ),
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
            ? "Wrong username or password."
            : e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isAdmin(Korisnik user) {
    final roles = user.ulogas;
    return roles != null && roles.any((role) => role.naziv == 'Administrator');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prijava")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: SizedBox(
              width: 500,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "Prijava na CineMatic",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Korisničko ime",
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Unesite korisničko ime" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Lozinka",
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value == null || value.isEmpty ? "Unesite lozinku" : null,
                        ),
                        if (_passwordError != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _passwordError!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.login),
                            label: Text("Prijavi se"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                              minimumSize: Size(120, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                          ),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(height: 24),
                          const CircularProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}