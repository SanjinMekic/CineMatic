import 'dart:convert';
import 'package:cinematic_desktop/models/korisnik.dart';
import 'package:cinematic_desktop/providers/auth_provider.dart';
import 'package:cinematic_desktop/providers/korisnik_provider.dart';
import 'package:cinematic_desktop/screens/login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Korisnik? _korisnik;
  bool _isLoading = true;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  String? _ime;
  String? _prezime;
  String? _email;
  String? _korisnickoIme;
  String? _lozinka;
  String? _lozinkaPotvrda;
  String? _slikaBase64;

  @override
  void initState() {
    super.initState();
    _fetchKorisnik();
  }

  Future<void> _fetchKorisnik() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    final id = AuthProvider.korisnikId;
    if (id != null) {
      final korisnik = await provider.getById(id);
      setState(() {
        _korisnik = korisnik;
        _ime = korisnik.ime;
        _prezime = korisnik.prezime;
        _email = korisnik.email;
        _korisnickoIme = korisnik.korisnickoIme;
        _slikaBase64 = korisnik.slikaBase64;
        _isLoading = false;
      });
    }
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

  String? _korisnickoImeError;
 Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = Provider.of<KorisnikProvider>(context, listen: false);

    bool korisnickoImePromijenjeno = _korisnickoIme != null && _korisnickoIme != _korisnik!.korisnickoIme;
    bool lozinkaPromijenjena = _lozinka != null && _lozinka!.isNotEmpty;

    if (korisnickoImePromijenjeno) {
      final zauzeto = await provider.korisnickoImeZauzeto(_korisnickoIme!);
      if (zauzeto) {
        setState(() {
          _korisnickoImeError = "Korisničko ime je zauzeto!";
        });
        return;
      } else {
        setState(() {
          _korisnickoImeError = null;
        });
      }
    }

    if (korisnickoImePromijenjeno || lozinkaPromijenjena) {
      final potvrda = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Potvrda izmjene"),
          content: Text(
            "Mijenjanje korisničkog imena ili šifre zahtijeva da se ponovo prijavite na aplikaciju.\n\nDa li ste sigurni da želite nastaviti?"
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Otkaži"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Nastavi"),
            ),
          ],
        ),
      );
      if (potvrda != true) return;
    }

    await provider.update(_korisnik!.id, {
      'ime': _ime,
      'prezime': _prezime,
      'email': _email,
      'korisnickoIme': _korisnickoIme,
      'slikaBase64': _slikaBase64,
      'lozinka': lozinkaPromijenjena ? _lozinka : null,
      'lozinkaPotvrda': lozinkaPromijenjena ? _lozinkaPotvrda : null,
    });

    if (korisnickoImePromijenjeno || lozinkaPromijenjena) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      setState(() => _isEditing = false);
      _fetchKorisnik();
    }
  }

  Future<void> _deleteProfile() async {
    String? enteredPassword;
    String? passwordError;

    bool passwordOk = false;

    passwordOk =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text("Potvrda brisanja profila"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Unesite šifru za potvrdu brisanja profila:"),
                      const SizedBox(height: 12),
                      TextField(
                        obscureText: true,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: "Šifra",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          enteredPassword = v;
                          if (passwordError != null) {
                            setState(() => passwordError = null);
                          }
                        },
                      ),
                      if (passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            passwordError!,
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Otkaži"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final provider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final korisnickoIme = _korisnik?.korisnickoIme ?? "";
                        final korisnik = await provider.login(
                          korisnickoIme,
                          enteredPassword ?? "",
                        );
                        if (korisnik != null) {
                          Navigator.of(context).pop(true);
                        } else {
                          setState(() {
                            passwordError = "Pogrešna šifra. Pokušajte ponovo.";
                          });
                        }
                      },
                      child: Text("Potvrdi"),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    if (!passwordOk) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Upozorenje"),
            content: Text("Da li ste sigurni da želite obrisati svoj profil?"),
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
      await provider.delete(_korisnik!.id);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = _korisnik?.korisnickoIme == "admin";

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child:
              _isEditing
                  ? Form(
                    key: _formKey,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 480),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage:
                                    _slikaBase64 != null
                                        ? MemoryImage(
                                          base64Decode(_slikaBase64!),
                                        )
                                        : null,
                                child:
                                    _slikaBase64 == null
                                        ? Icon(Icons.person, size: 70)
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Uredi profil",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              initialValue: _ime,
                              decoration: InputDecoration(
                                labelText: "Ime",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? "Obavezno polje"
                                          : null,
                              onSaved: (v) => _ime = v,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _prezime,
                              decoration: InputDecoration(
                                labelText: "Prezime",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? "Obavezno polje"
                                          : null,
                              onSaved: (v) => _prezime = v,
                            ),
                            const SizedBox(height: 16),
                            if (!isAdmin)
                              TextFormField(
                                initialValue: _korisnickoIme,
                                decoration: InputDecoration(
                                  labelText: "Korisničko ime",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.account_circle),
                                  errorText: _korisnickoImeError,
                                ),
                                validator:
                                    (v) =>
                                        v == null || v.isEmpty
                                            ? "Obavezno polje"
                                            : null,
                                onSaved: (v) => _korisnickoIme = v,
                              ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _email,
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? "Obavezno polje"
                                          : null,
                              onSaved: (v) => _email = v,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Nova lozinka",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              onChanged: (v) => _lozinka = v,
                              validator: (v) {
                                if (v != null &&
                                    v.isNotEmpty &&
                                    (_lozinkaPotvrda == null ||
                                        _lozinkaPotvrda!.isEmpty)) {
                                  return "Unesite potvrdu lozinke";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Potvrda lozinke",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              onChanged: (v) => _lozinkaPotvrda = v,
                              validator: (v) {
                                if ((_lozinka != null &&
                                    _lozinka!.isNotEmpty)) {
                                  if (v == null || v.isEmpty) {
                                    return "Unesite potvrdu lozinke";
                                  }
                                  if (v != _lozinka) {
                                    return "Lozinke se ne podudaraju";
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed:
                                      () => setState(() => _isEditing = false),
                                  child: Text("Otkaži"),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    textStyle: TextStyle(fontSize: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text("Sačuvaj"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  )
                  : Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 48,
                            horizontal: 48,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    _korisnik?.slikaBase64 != null
                                        ? MemoryImage(
                                          base64Decode(_korisnik!.slikaBase64!),
                                        )
                                        : null,
                                child:
                                    _korisnik?.slikaBase64 == null
                                        ? Icon(Icons.person, size: 80)
                                        : null,
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "${_korisnik?.ime ?? ""} ${_korisnik?.prezime ?? ""}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_circle,
                                    size: 22,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _korisnik?.korisnickoIme ?? "",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 22,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _korisnik?.email ?? "",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.edit, size: 22),
                                      label: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                        ),
                                        child: Text(
                                          "Uredi profil",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          () =>
                                              setState(() => _isEditing = true),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical: 10,
                                        ),
                                        textStyle: TextStyle(fontSize: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isAdmin) ...[
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 180,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 22,
                                          color: Colors.red,
                                        ),
                                        label: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                          ),
                                          child: Text(
                                            "Obriši profil",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        onPressed: _deleteProfile,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 10,
                                          ),
                                          textStyle: TextStyle(fontSize: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          foregroundColor: Colors.red,
                                          side: BorderSide(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
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
