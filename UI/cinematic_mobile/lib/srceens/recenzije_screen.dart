import 'dart:convert';
import 'package:cinematic_mobile/models/recenzija.dart';
import 'package:cinematic_mobile/providers/recenzija_provider.dart';
import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecenzijeScreen extends StatefulWidget {
  final int filmId;
  const RecenzijeScreen({super.key, required this.filmId});

  @override
  State<RecenzijeScreen> createState() => _RecenzijeScreenState();
}

class _RecenzijeScreenState extends State<RecenzijeScreen> {
  List<Recenzija> _recenzije = [];
  bool _isLoading = true;

  // Za unos nove recenzije
  final TextEditingController _komentarController = TextEditingController();
  double _novaOcjena = 5;
  bool _saljeSe = false;

  @override
  void initState() {
    super.initState();
    _fetchRecenzije();
  }

  Future<void> _fetchRecenzije() async {
  final provider = Provider.of<RecenzijaProvider>(context, listen: false);
  try {
    final result = await provider.getByFilm(widget.filmId);

    // Ispisi sve podatke iz rezultata
    for (var rec in result) {
      print('Recenzija: ${jsonEncode(rec.toJson())}');
    }

    setState(() {
      _recenzije = result;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
  }
}

  double get _ukupnaOcjena {
    if (_recenzije.isEmpty) return 0;
    return _recenzije.map((r) => r.ocjena ?? 0).reduce((a, b) => a + b) /
        _recenzije.length;
  }

  Future<void> _posaljiRecenziju() async {
    if (_komentarController.text.trim().isEmpty) return;
    if (AuthProvider.korisnikId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Morate biti prijavljeni da biste ostavili recenziju."),
        ),
      );
      return;
    }
    setState(() {
      _saljeSe = true;
    });

    try {
      final provider = Provider.of<RecenzijaProvider>(context, listen: false);
      final recenzija = {
        "korisnikId": AuthProvider.korisnikId,
        "filmId": widget.filmId,
        "ocjena": _novaOcjena.round(),
        "datumIvrijeme": DateTime.now().toIso8601String(),
        "komentar": _komentarController.text.trim(),
      };
      await provider.insert(recenzija);
      _komentarController.clear();
      _novaOcjena = 5;
      await _fetchRecenzije();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recenzija uspješno dodana!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Greška pri slanju recenzije.")),
        );
      }
    } finally {
      setState(() {
        _saljeSe = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recenzije filma")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      color: Colors.blue[50],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _ukupnaOcjena.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(${_recenzije.length} recenzija)",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dodaj svoju recenziju",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  "Ocjena:",
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 10),
                                for (int i = 1; i <= 5; i++)
                                  IconButton(
                                    icon: Icon(
                                      i <= _novaOcjena
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                    ),
                                    onPressed:
                                        _saljeSe
                                            ? null
                                            : () {
                                              setState(() {
                                                _novaOcjena = i.toDouble();
                                              });
                                            },
                                  ),
                              ],
                            ),
                            TextField(
                              controller: _komentarController,
                              enabled: !_saljeSe,
                              maxLines: 3,
                              maxLength: 300,
                              decoration: const InputDecoration(
                                labelText: "Komentar",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.send),
                                label: const Text("Pošalji recenziju"),
                                onPressed: _saljeSe ? null : _posaljiRecenziju,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child:
                          _recenzije.isEmpty
                              ? const Center(
                                child: Text("Nema recenzija za ovaj film."),
                              )
                              : ListView.separated(
                                itemCount: _recenzije.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final r = _recenzije[index];
                                  final korisnik = r.korisnik;
                                  final datum =
                                      r.datumIvrijeme != null
                                          ? DateFormat(
                                            'dd.MM.yyyy. HH:mm',
                                          ).format(r.datumIvrijeme!)
                                          : "";

                                  // Ispis u konzolu
                                  if (korisnik?.slikaBase64 != null &&
                                      korisnik!.slikaBase64!.isNotEmpty) {
                                    print(
                                      'Korisnik ${korisnik.ime} ima sliku: ${korisnik.slikaBase64!.substring(0, korisnik.slikaBase64!.length > 50 ? 50 : korisnik.slikaBase64!.length)}...',
                                    );
                                  } else {
                                    print(
                                      'Korisnik ${korisnik?.ime ?? "Nepoznat"} nema sliku.',
                                    );
                                  }

                                  ImageProvider? imageProvider;
                                  if (korisnik?.slikaBase64 != null &&
                                      korisnik!.slikaBase64!.isNotEmpty) {
                                    try {
                                      final base64Str =
                                          korisnik.slikaBase64!.contains(',')
                                              ? korisnik.slikaBase64!
                                                  .split(',')
                                                  .last
                                              : korisnik.slikaBase64!;
                                      imageProvider = MemoryImage(
                                        base64Decode(base64Str),
                                      );
                                    } catch (e) {
                                      print(
                                        'Greška kod dekodiranja slike za korisnika ${korisnik.ime}: $e',
                                      );
                                      imageProvider = null;
                                    }
                                  }

                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: Colors.blue[100],
                                            backgroundImage: imageProvider,
                                            child:
                                                imageProvider == null
                                                    ? Icon(
                                                      Icons.person,
                                                      size: 28,
                                                      color: Colors.blue,
                                                    )
                                                    : null,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${korisnik?.ime ?? "Nepoznat"} ${korisnik?.prezime ?? ""}",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 18,
                                                    ),
                                                    Text(
                                                      "${r.ocjena ?? "-"}",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (datum.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2.0,
                                                          bottom: 6,
                                                        ),
                                                    child: Text(
                                                      datum,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                Text(
                                                  r.komentar ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
