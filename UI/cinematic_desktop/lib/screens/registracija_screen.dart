// import 'package:cinematic_desktop/models/korisnik.dart';
// import 'package:cinematic_desktop/providers/korisnik_provider.dart';
// import 'package:flutter/material.dart';

// class RegistracijaScreen extends StatefulWidget {
//   const RegistracijaScreen({super.key});

//   @override
//   State<RegistracijaScreen> createState() => _RegistracijaScreenState();
// }

// class _RegistracijaScreenState extends State<RegistracijaScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _imeController = TextEditingController();
//   final _prezimeController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _korisnickoImeController = TextEditingController();
//   final _lozinkaController = TextEditingController();
//   final _lozinkaPotvrdaController = TextEditingController();

//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Registracija")),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: _imeController,
//                   decoration: InputDecoration(labelText: "Ime"),
//                   validator:
//                       (value) =>
//                           value == null || value.isEmpty ? "Unesite ime" : null,
//                 ),
//                 SizedBox(height: 12),
//                 TextFormField(
//                   controller: _prezimeController,
//                   decoration: InputDecoration(labelText: "Prezime"),
//                   validator:
//                       (value) =>
//                           value == null || value.isEmpty
//                               ? "Unesite prezime"
//                               : null,
//                 ),
//                 SizedBox(height: 12),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(labelText: "Email"),
//                   validator:
//                       (value) =>
//                           value == null || value.isEmpty
//                               ? "Unesite email"
//                               : null,
//                 ),
//                 SizedBox(height: 12),
//                 TextFormField(
//                   controller: _korisnickoImeController,
//                   decoration: InputDecoration(labelText: "Korisničko ime"),
//                   validator:
//                       (value) =>
//                           value == null || value.isEmpty
//                               ? "Unesite korisničko ime"
//                               : null,
//                 ),
//                 SizedBox(height: 12),
//                 TextFormField(
//                   controller: _lozinkaController,
//                   decoration: InputDecoration(labelText: "Lozinka"),
//                   obscureText: true,
//                   validator:
//                       (value) =>
//                           value == null || value.isEmpty
//                               ? "Unesite lozinku"
//                               : null,
//                 ),
//                 SizedBox(height: 12),
//                 TextFormField(
//                   controller: _lozinkaPotvrdaController,
//                   decoration: InputDecoration(labelText: "Potvrda lozinke"),
//                   obscureText: true,
//                   validator:
//                       (value) =>
//                           value != _lozinkaController.text
//                               ? "Lozinke se ne podudaraju"
//                               : null,
//                 ),
//                 SizedBox(height: 24),
//                 _loading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           setState(() => _loading = true);
//                           KorisnikProvider provider = KorisnikProvider();
//                           final korisnik = Korisnik(
//                             ime: _imeController.text,
//                             prezime: _prezimeController.text,
//                             email: _emailController.text,
//                             korisnickoIme: _korisnickoImeController.text,
//                             lozinka: _lozinkaController.text,
//                             lozinkaPotvrda: _lozinkaPotvrdaController.text,
//                             slikaBase64: null,
//                           );
//                           try {
//                             await provider.insert(korisnik.toJson());
//                             setState(() => _loading = false);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Registracija uspješna!")),
//                             );
//                             Navigator.pop(context);
//                             return;
//                           } catch (e) {
//                             setState(() => _loading = false);
//                             print("Greška: $e");
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text("Greška pri registraciji!"),
//                               ),
//                             );
//                           }
//                         }
//                       },
//                       child: Text("Registruj se"),
//                     ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
