import 'dart:convert';
import 'package:cinematic_mobile/providers/korisnik_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistracijaScreen extends StatefulWidget {
  const RegistracijaScreen({super.key});

  @override
  State<RegistracijaScreen> createState() => _RegistracijaScreenState();
}

class _RegistracijaScreenState extends State<RegistracijaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _emailController = TextEditingController();
  final _korisnickoImeController = TextEditingController();
  final _lozinkaController = TextEditingController();
  final _lozinkaPotvrdaController = TextEditingController();
  String? _slikaBase64;
  bool _isLoading = false;
  String? _error;
  String? _korisnickoImeError;
  String? _slikaError; // Dodano za prikaz greške

  Future<void> _pickImage() async {
    setState(() {
      _slikaError = null;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final ext = result.files.single.extension?.toLowerCase();
      if (ext == 'heic') {
        setState(() {
          _slikaError = "HEIC format nije dozvoljen. Dozvoljeni su samo PNG, JPG i JPEG.";
        });
        return;
      }
      setState(() {
        _slikaBase64 = base64Encode(result.files.single.bytes!);
        _slikaError = null;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _korisnickoImeError = null;
    });

    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    final korisnickoIme = _korisnickoImeController.text.trim();

    // Provjera da li je korisničko ime zauzeto
    final zauzeto = await provider.korisnickoImeZauzeto(korisnickoIme);
    if (zauzeto) {
      setState(() {
        _korisnickoImeError = "Korisničko ime je zauzeto, molimo unesite drugo.";
        _isLoading = false;
      });
      return;
    }

    final body = {
      "ime": _imeController.text.trim(),
      "prezime": _prezimeController.text.trim(),
      "email": _emailController.text.trim(),
      "korisnickoIme": korisnickoIme,
      "slikaBase64": _slikaBase64,
      "lozinka": _lozinkaController.text,
      "lozinkaPotvrda": _lozinkaPotvrdaController.text,
      "ulogaId": [1],
    };

    try {
      await provider.insert(body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registracija uspješna! Prijavite se.')),
        );
        Navigator.of(context).pop(); // Vrati na login
      }
    } catch (e) {
      setState(() {
        _error = 'Greška: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Registracija'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Kreirajte novi nalog",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _imeController,
                      decoration: const InputDecoration(labelText: "Ime"),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Unesite ime" : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _prezimeController,
                      decoration: const InputDecoration(labelText: "Prezime"),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Unesite prezime" : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Unesite email";
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(v.trim()))
                          return "Unesite validan email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _korisnickoImeController,
                      decoration: const InputDecoration(
                        labelText: "Korisničko ime",
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Unesite korisničko ime" : null,
                    ),
                    if (_korisnickoImeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          _korisnickoImeError!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _lozinkaController,
                      decoration: const InputDecoration(labelText: "Lozinka"),
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Unesite lozinku" : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _lozinkaPotvrdaController,
                      decoration: const InputDecoration(
                        labelText: "Potvrda lozinke",
                      ),
                      obscureText: true,
                      validator: (v) =>
                          v != _lozinkaController.text ? "Lozinke se ne podudaraju" : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Dodaj sliku (opcionalno)"),
                        ),
                        if (_slikaBase64 != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: MemoryImage(
                                base64Decode(_slikaBase64!),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_slikaError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          _slikaError!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _register();
                                }
                              },
                              child: const Text("Registruj se"),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}