import 'package:cinematic_desktop/models/korisnik.dart';
import 'package:cinematic_desktop/providers/korisnik_provider.dart';
import 'package:cinematic_desktop/screens/dodaj_korisnika_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class KorisniciAdminiScreen extends StatefulWidget {
  const KorisniciAdminiScreen({super.key});

  @override
  State<KorisniciAdminiScreen> createState() => _KorisniciAdminiScreenState();
}

class _KorisniciAdminiScreenState extends State<KorisniciAdminiScreen> {
  List<Korisnik> _korisnici = [];
  bool _isLoading = true;

  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _korisnickoImeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKorisnici();
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _korisnickoImeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchKorisnici() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<KorisnikProvider>(context, listen: false);

    final filter = {
      'isUlogeIncluded': true,
      if (_imeController.text.trim().isNotEmpty)
        'ImeGTE': _imeController.text.trim(),
      if (_prezimeController.text.trim().isNotEmpty)
        'PrezimeGTE': _prezimeController.text.trim(),
      if (_korisnickoImeController.text.trim().isNotEmpty)
        'KorisnickoIme': _korisnickoImeController.text.trim(),
      if (_emailController.text.trim().isNotEmpty)
        'Email': _emailController.text.trim(),
    };

    final result = await provider.get(filter: filter);
    setState(() {
      _korisnici = result.result;
      _isLoading = false;
    });
  }

  bool _isAdmin(Korisnik korisnik) {
    return korisnik.ulogas?.any(
          (u) => (u.naziv?.toLowerCase() == "administrator"),
        ) ==
        true;
  }

  Future<void> _editKorisnik(Korisnik korisnik) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DodajKorisnikaScreen(korisnik: korisnik),
      ),
    );
    if (result == true) _fetchKorisnici();
  }

  Future<void> _deleteKorisnik(Korisnik korisnik) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Potvrda brisanja"),
            content: Text(
              "Da li ste sigurni da želite obrisati korisnika \"${korisnik.ime ?? ""} ${korisnik.prezime ?? ""}\"?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Otkaži"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Obriši", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final provider = Provider.of<KorisnikProvider>(context, listen: false);
      await provider.delete(korisnik.id);
      _fetchKorisnici();
    }
  }

  @override
  Widget build(BuildContext context) {
    final admini = _korisnici.where(_isAdmin).toList();
    final obicni = _korisnici.where((k) => !_isAdmin(k)).toList();

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  children: [
                    // Search fields
                    Card(
                      margin: EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _imeController,
                                    decoration: InputDecoration(
                                      labelText: "Ime",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _prezimeController,
                                    decoration: InputDecoration(
                                      labelText: "Prezime",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _korisnickoImeController,
                                    decoration: InputDecoration(
                                      labelText: "Korisničko ime",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.search),
                                label: Text("Pretraži"),
                                onPressed: _fetchKorisnici,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.person_add),
                      label: Text("Dodaj admina/korisnika"),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DodajKorisnikaScreen(),
                          ),
                        );
                        if (result == true) _fetchKorisnici();
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Administratori",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    admini.isEmpty
                        ? const Text("Nema administratora.")
                        : Column(
                          children:
                              admini
                                  .map(
                                    (k) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            k.slikaBase64 != null
                                                ? MemoryImage(
                                                  base64Decode(k.slikaBase64!),
                                                )
                                                : null,
                                        child:
                                            k.slikaBase64 == null
                                                ? Icon(Icons.person)
                                                : null,
                                      ),
                                      title: Text(
                                        "${k.ime ?? ""} ${k.prezime ?? ""}",
                                      ),
                                      subtitle: Text(k.korisnickoIme ?? ""),
                                      trailing: Text(
                                        k.email ?? "",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    const SizedBox(height: 32),
                    Text(
                      "Korisnici",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    obicni.isEmpty
                        ? const Text("Nema korisnika.")
                        : Column(
                          children:
                              obicni
                                  .map(
                                    (k) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            k.slikaBase64 != null
                                                ? MemoryImage(
                                                  base64Decode(k.slikaBase64!),
                                                )
                                                : null,
                                        child:
                                            k.slikaBase64 == null
                                                ? Icon(Icons.person)
                                                : null,
                                      ),
                                      title: Text(
                                        "${k.ime ?? ""} ${k.prezime ?? ""}",
                                      ),
                                      subtitle: Text(k.korisnickoIme ?? ""),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            k.email ?? "",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            tooltip: "Uredi korisnika",
                                            onPressed: () => _editKorisnik(k),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            tooltip: "Obriši korisnika",
                                            onPressed: () => _deleteKorisnik(k),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                  ],
                ),
              ),
    );
  }
}
