import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:cinematic_mobile/layouts/master_screen.dart';
import 'package:cinematic_mobile/models/korisnik.dart';
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

        if (_isAdmin(response)) {
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

  bool _isAdmin(Korisnik user) {
    final roles = user.ulogas;
    return roles != null && roles.any((role) => role.naziv == 'Korisnik');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prijava")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Korisničko ime"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Unesite korisničko ime" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Lozinka"),
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Unesite lozinku" : null,
                ),
                if (_passwordError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _passwordError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        child: const Text("Prijavi se"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}