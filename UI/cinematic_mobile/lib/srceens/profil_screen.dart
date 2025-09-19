import 'dart:convert';
import 'package:cinematic_mobile/models/korisnik.dart';
import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:cinematic_mobile/providers/korisnik_provider.dart';
import 'package:cinematic_mobile/srceens/login_screen.dart';
import 'package:cinematic_mobile/srceens/promjena_sifre_screen.dart';
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    await provider.update(_korisnik!.id, {
      'ime': _ime,
      'prezime': _prezime,
      'email': _email,
      'korisnickoIme': _korisnickoIme,
      'slikaBase64': _slikaBase64,
    });
    setState(() => _isEditing = false);
    _fetchKorisnik();
  }

  void _logout() {
    AuthProvider.username = null;
    AuthProvider.password = null;
    AuthProvider.korisnikId = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _obrisiNalog() async {
    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    final id = AuthProvider.korisnikId;
    if (id == null) return;

    try {
      await provider.delete(id);
      AuthProvider.username = null;
      AuthProvider.password = null;
      AuthProvider.korisnikId = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Korisnički nalog je obrisan.")),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri brisanju naloga: $e")),
      );
    }
  }

  void _showDeleteDialog() {
  String sifra = '';
  String? errorMsg;
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Potvrda brisanja naloga"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Unesite svoju šifru za potvrdu brisanja naloga:",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Šifra",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  sifra = v;
                  if (errorMsg != null) setState(() => errorMsg = null);
                },
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Otkaži"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (sifra != AuthProvider.password) {
                  setState(() {
                    errorMsg = "Pogrešna šifra!";
                  });
                  return;
                }
                Navigator.of(context).pop();
                final potvrda = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Jeste li sigurni?"),
                    content: const Text(
                      "Ova akcija je nepovratna. Da li zaista želite obrisati svoj korisnički nalog?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Ne"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Da, obriši"),
                      ),
                    ],
                  ),
                );
                if (potvrda == true) {
                  await _obrisiNalog();
                }
              },
              child: const Text("Obriši nalog"),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _isEditing
              ? Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _slikaBase64 != null
                              ? MemoryImage(base64Decode(_slikaBase64!))
                              : null,
                          child: _slikaBase64 == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Uredi profil",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: _ime,
                        decoration: const InputDecoration(
                          labelText: "Ime",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Obavezno polje" : null,
                        onSaved: (v) => _ime = v,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _prezime,
                        decoration: const InputDecoration(
                          labelText: "Prezime",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Obavezno polje" : null,
                        onSaved: (v) => _prezime = v,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _korisnickoIme,
                        decoration: const InputDecoration(
                          labelText: "Korisničko ime",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Obavezno polje" : null,
                        onSaved: (v) => _korisnickoIme = v,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _email,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Obavezno polje" : null,
                        onSaved: (v) => _email = v,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PromjenaSifreScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Promijeni šifru?",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _showDeleteDialog,
                          child: const Text(
                            "Obrišite korisnički nalog?",
                            style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _isEditing = false),
                            child: const Text("Otkaži"),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Sačuvaj"),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _korisnik?.slikaBase64 != null
                          ? MemoryImage(base64Decode(_korisnik!.slikaBase64!))
                          : null,
                      child: _korisnik?.slikaBase64 == null
                          ? const Icon(Icons.person, size: 70)
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "${_korisnik?.ime ?? ""} ${_korisnik?.prezime ?? ""}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_circle,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _korisnik?.korisnickoIme ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _korisnik?.email ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Odjavi se",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Uredi profil",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () => setState(() => _isEditing = true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}