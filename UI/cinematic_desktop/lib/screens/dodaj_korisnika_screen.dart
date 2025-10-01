import 'dart:convert';
import 'package:cinematic_desktop/models/korisnik.dart';
import 'package:cinematic_desktop/models/uloga.dart';
import 'package:cinematic_desktop/providers/korisnik_provider.dart';
import 'package:cinematic_desktop/providers/uloga_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DodajKorisnikaScreen extends StatefulWidget {
  final Korisnik? korisnik;

  const DodajKorisnikaScreen({super.key, this.korisnik});

  @override
  State<DodajKorisnikaScreen> createState() => _DodajKorisnikaScreenState();
}

class _DodajKorisnikaScreenState extends State<DodajKorisnikaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _ime, _prezime, _email, _korisnickoIme, _slikaBase64;
  int? _ulogaId;
  List<Uloga> _uloge = [];
  bool _isLoading = true;
  String? _korisnickoImeError;
  bool _isSaving = false; // Dodano za disable dugmeta

  final _lozinkaController = TextEditingController();
  final _lozinkaPotvrdaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUloge().then((_) {
      if (widget.korisnik != null) {
        _ime = widget.korisnik!.ime;
        _prezime = widget.korisnik!.prezime;
        _email = widget.korisnik!.email;
        _korisnickoIme = widget.korisnik!.korisnickoIme;
        _slikaBase64 = widget.korisnik!.slikaBase64;
        if (widget.korisnik!.ulogas != null && widget.korisnik!.ulogas!.isNotEmpty) {
          _ulogaId = widget.korisnik!.ulogas!.first.id;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lozinkaController.dispose();
    _lozinkaPotvrdaController.dispose();
    super.dispose();
  }

  Future<void> _fetchUloge() async {
    final provider = Provider.of<UlogaProvider>(context, listen: false);
    final result = await provider.get();
    setState(() {
      _uloge = result.result;
      _isLoading = false;
      if (_uloge.isNotEmpty && _ulogaId == null) _ulogaId = _uloge.first.id;
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _slikaBase64 = base64Encode(result.files.single.bytes!);
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _korisnickoImeError = null;
    });

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true; // Disable dugme
    });

    final provider = Provider.of<KorisnikProvider>(context, listen: false);

    if (widget.korisnik == null) {
      final zauzeto = await provider.korisnickoImeZauzeto(_korisnickoIme ?? "");
      if (zauzeto) {
        setState(() {
          _korisnickoImeError = "Korisničko ime je zauzeto!";
          _isSaving = false; // Omogući dugme
        });
        return;
      }
    }

    final data = {
      'ime': _ime,
      'prezime': _prezime,
      'email': _email,
      'korisnickoIme': _korisnickoIme,
      'slikaBase64': _slikaBase64,
      if (widget.korisnik == null)
        'lozinka':
            _lozinkaController.text.isNotEmpty ? _lozinkaController.text : null,
      if (widget.korisnik == null)
        'lozinkaPotvrda':
            _lozinkaPotvrdaController.text.isNotEmpty
                ? _lozinkaPotvrdaController.text
                : null,
      if (_ulogaId != null)
        'ulogaId': [_ulogaId!],
    };

    if (widget.korisnik == null) {
      await provider.insert(data);
    } else {
      await provider.update(widget.korisnik!.id, data);
    }

    if (mounted) Navigator.of(context).pop(true);
    // Dugme ostaje disabled dok se ne ode na prethodni screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.korisnik == null ? "Dodaj korisnika" : "Uredi korisnika",
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 40,
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 48,
                                      backgroundImage: _slikaBase64 != null
                                          ? MemoryImage(
                                              base64Decode(_slikaBase64!),
                                            )
                                          : null,
                                      child: _slikaBase64 == null
                                          ? Icon(Icons.person, size: 48)
                                          : null,
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.add_circle,
                                          color: Colors.blue,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _ime,
                            decoration: InputDecoration(labelText: "Ime"),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? "Obavezno polje"
                                    : null,
                            onSaved: (v) => _ime = v,
                          ),
                          TextFormField(
                            initialValue: _prezime,
                            decoration: InputDecoration(labelText: "Prezime"),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? "Obavezno polje"
                                    : null,
                            onSaved: (v) => _prezime = v,
                          ),
                          TextFormField(
                            initialValue: _korisnickoIme,
                            decoration: InputDecoration(
                              labelText: "Korisničko ime",
                              errorText: _korisnickoImeError,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? "Obavezno polje"
                                    : null,
                            onSaved: (v) => _korisnickoIme = v,
                          ),
                          TextFormField(
                            initialValue: _email,
                            decoration: InputDecoration(labelText: "Email"),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Obavezno polje";
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(v))
                                return "Unesite validan email";
                              return null;
                            },
                            onSaved: (v) => _email = v,
                          ),
                          DropdownButtonFormField<int>(
                            value: _ulogaId,
                            items: _uloge
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u.id,
                                    child: Text(u.naziv ?? ""),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _ulogaId = v),
                            decoration: InputDecoration(labelText: "Uloga"),
                            validator: (v) =>
                                v == null ? "Odaberite ulogu" : null,
                          ),
                          if (widget.korisnik == null) ...[
                            TextFormField(
                              controller: _lozinkaController,
                              decoration: InputDecoration(
                                labelText: "Lozinka",
                              ),
                              obscureText: true,
                              validator: (v) {
                                if (widget.korisnik == null &&
                                    (v == null || v.isEmpty)) {
                                  return "Obavezno polje";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _lozinkaPotvrdaController,
                              decoration: InputDecoration(
                                labelText: "Potvrda lozinke",
                              ),
                              obscureText: true,
                              validator: (v) {
                                if (widget.korisnik == null &&
                                    (v == null || v.isEmpty)) {
                                  return "Obavezno polje";
                                }
                                if (_lozinkaController.text.isNotEmpty &&
                                    v != _lozinkaController.text) {
                                  return "Lozinke se ne podudaraju";
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("Otkaži"),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _save,
                                child: Text("Sačuvaj"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          )
    );
  }
}