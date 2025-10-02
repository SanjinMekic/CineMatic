import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:cinematic_mobile/providers/korisnik_provider.dart';
import 'package:cinematic_mobile/srceens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromjenaSifreScreen extends StatefulWidget {
  const PromjenaSifreScreen({super.key});

  @override
  State<PromjenaSifreScreen> createState() => _PromjenaSifreScreenState();
}

class _PromjenaSifreScreenState extends State<PromjenaSifreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _staraSifraController = TextEditingController();
  final _novaSifraController = TextEditingController();
  final _potvrdaNoveSifreController = TextEditingController();

  String? _staraSifraError;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _staraSifraController.dispose();
    _novaSifraController.dispose();
    _potvrdaNoveSifreController.dispose();
    super.dispose();
  }

  Future<void> _promijeniSifru() async {
  setState(() {
    _staraSifraError = null;
    _error = null;
  });

  if (!_formKey.currentState!.validate()) return;

  final potvrda = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Potvrda izmjene šifre"),
      content: const Text("Da li ste sigurni da želite izmijeniti šifru?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Odustani"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Izmijeni"),
        ),
      ],
    ),
  );
  if (potvrda != true) return;

  setState(() {
    _isLoading = true;
  });

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
  final korisnikId = AuthProvider.korisnikId;
  final username = AuthProvider.username;

  try {
    final user = await authProvider.login(username!, _staraSifraController.text);
    if (user == null) {
      setState(() {
        _staraSifraError = "Stara šifra nije ispravna.";
      });
      return;
    }
    await korisnikProvider.update(korisnikId!, {
      'lozinka': _novaSifraController.text,
      'lozinkaPotvrda': _potvrdaNoveSifreController.text,
    });
    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Promjena šifre"),
          content: const Text(
            "Šifra je uspješno promijenjena. Bit ćete preusmjereni na login ekran.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("U redu"),
            ),
          ],
        ),
      );
      AuthProvider.username = null;
      AuthProvider.password = null;
      AuthProvider.korisnikId = null;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  } catch (e) {
    setState(() {
      _error = "Greška: ${e.toString()}";
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
      appBar: AppBar(title: const Text("Promjena šifre")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _staraSifraController,
                decoration: InputDecoration(
                  labelText: "Stara šifra",
                  border: const OutlineInputBorder(),
                  errorText: _staraSifraError,
                ),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? "Unesite staru šifru" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _novaSifraController,
                decoration: const InputDecoration(
                  labelText: "Nova šifra",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Unesite novu šifru";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _potvrdaNoveSifreController,
                decoration: const InputDecoration(
                  labelText: "Potvrda nove šifre",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Potvrdite novu šifru";
                  if (v != _novaSifraController.text) return "Šifre se ne podudaraju";
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _promijeniSifru,
                      child: const Text("Promijeni šifru"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}