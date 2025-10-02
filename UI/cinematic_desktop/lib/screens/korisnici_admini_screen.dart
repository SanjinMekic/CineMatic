import 'package:cinematic_desktop/models/korisnik.dart';
import 'package:cinematic_desktop/providers/auth_provider.dart';
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

  bool _isBlagajnik(Korisnik korisnik) {
    return korisnik.ulogas?.any(
          (u) => (u.naziv?.toLowerCase() == "blagajnik"),
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

  Future<void> _aktivirajObrisanogKorisnika(Korisnik korisnik) async {
    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    try {
      await provider.aktivirajObrisanogKorisnika(korisnik.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Korisnik je uspješno aktiviran.")),
      );
      _fetchKorisnici();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sistemAdmini =
        _korisnici
            .where(
              (k) =>
                  _isAdmin(k) &&
                  (k.korisnickoIme == "admin") &&
                  (k.obrisan != true),
            )
            .toList();
    final admini =
        _korisnici.where((k) => _isAdmin(k) && (k.korisnickoIme != "admin") && (k.obrisan != true)).toList();
    final blagajnici =
        _korisnici
            .where(
              (k) => _isBlagajnik(k) && !_isAdmin(k) && (k.obrisan != true),
            )
            .toList();
    final obicni =
        _korisnici
            .where(
              (k) => !_isAdmin(k) && !_isBlagajnik(k) && (k.obrisan != true),
            )
            .toList();
    final obrisani = _korisnici.where((k) => k.obrisan == true).toList();

    final isSistemAdminLoggedIn = AuthProvider.username == "admin";

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  children: [
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.search),
                                  label: Text("Pretraži"),
                                  onPressed: _fetchKorisnici,
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.clear),
                                  label: Text("Očisti filtere"),
                                  onPressed: () {
                                    _imeController.clear();
                                    _prezimeController.clear();
                                    _korisnickoImeController.clear();
                                    _emailController.clear();
                                    _fetchKorisnici();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.person_add),
                      label: Text("Dodaj admina/blagajnika/korisnika"),
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
                      "Sistem administrator",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    sistemAdmini.isEmpty
                        ? const Text("Nema sistem administratora.")
                        : Column(
                          children:
                              sistemAdmini
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
                            children: admini
                                .map(
                                  (k) => ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: k.slikaBase64 != null
                                          ? MemoryImage(base64Decode(k.slikaBase64!))
                                          : null,
                                      child: k.slikaBase64 == null
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
                                        if (isSistemAdminLoggedIn) ...[
      const SizedBox(width: 8),
      IconButton(
        icon: Icon(
          Icons.edit,
          color: Colors.blue,
        ),
        tooltip: "Uredi administratora",
        onPressed: () => _editKorisnik(k),
      ),
      IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        tooltip: "Obriši administratora",
        onPressed: () => _deleteKorisnik(k),
      ),
    ],
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                    const SizedBox(height: 32),
                    Text(
                      "Blagajnici",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    blagajnici.isEmpty
                        ? const Text("Nema blagajnika.")
                        : Column(
                          children:
                              blagajnici
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
                    const SizedBox(height: 32),
                    Text(
                      "Obrisani korisnici",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    obrisani.isEmpty
                        ? const Text("Nema obrisanih korisnika.")
                        : Column(
                          children:
                              obrisani
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
                                        style: TextStyle(
                                          color: Colors.red[700],
                                        ),
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
                                          ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            label: Text("Aktiviraj"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                            onPressed: () async {
                                              final potvrdi = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: Text(
                                                        "Aktiviraj korisnika",
                                                      ),
                                                      content: Text(
                                                        "Da li ste sigurni da želite aktivirati korisnika \"${k.ime ?? ""} ${k.prezime ?? ""}\"?",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(false),
                                                          child: Text("Otkaži"),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true),
                                                          child: Text(
                                                            "Aktiviraj",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (potvrdi == true) {
                                                await _aktivirajObrisanogKorisnika(
                                                  k,
                                                );
                                              }
                                            },
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
