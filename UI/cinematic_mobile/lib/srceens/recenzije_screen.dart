import 'dart:convert';
import 'package:cinematic_mobile/models/recenzija.dart';
import 'package:cinematic_mobile/providers/recenzija_provider.dart';
import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:cinematic_mobile/providers/korisnik_provider.dart';
import 'package:cinematic_mobile/models/korisnik.dart';
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
  double _ukupnaOcjena = 0.0;

  final TextEditingController _komentarController = TextEditingController();
  double _novaOcjena = 5;
  bool _saljeSe = false;
  Recenzija? _mojaRecenzija;

  Map<int, Korisnik?> _korisniciRecenzija = {};

  @override
  void initState() {
    super.initState();
    _fetchRecenzije();
  }

  Future<void> _fetchRecenzije() async {
    final provider = Provider.of<RecenzijaProvider>(context, listen: false);
    try {
      final result = await provider.getByFilm(widget.filmId);
      final avg = await provider.getAverageRating(widget.filmId);

      final mojId = AuthProvider.korisnikId;
      Recenzija? moja;
      bool vecKomentarisano = false;
      if (mojId != null) {
        vecKomentarisano = await provider.vecOcijenjeno(mojId, widget.filmId);
        if (vecKomentarisano) {
          moja = result.firstWhere(
  (rec) => rec.korisnikId == mojId,
  orElse: () => Recenzija(), // Vrati prazan Recenzija objekat
);
if (moja.id == null) {
  moja = null;
}
        }
      }

      // Dohvati korisnike za sve recenzije
      final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
      Map<int, Korisnik?> korisnici = {};
      for (var rec in result) {
        if (rec.korisnikId != null) {
          try {
            final k = await korisnikProvider.getById(rec.korisnikId!);
            korisnici[rec.korisnikId!] = k;
          } catch (_) {
            korisnici[rec.korisnikId!] = Korisnik(
              id: rec.korisnikId!,
              ime: null,
              prezime: null,
              korisnickoIme: null,
              email: null,
              slikaBase64: null,
              ulogas: null,
              obrisan: true,
            );
          }
        }
      }

      setState(() {
        _recenzije = result;
        _mojaRecenzija = moja;
        _korisniciRecenzija = korisnici;
        _ukupnaOcjena = avg;
        if (moja != null) {
          _komentarController.text = moja.komentar ?? "";
          _novaOcjena = (moja.ocjena ?? 5).toDouble();
        } else {
          _komentarController.clear();
          _novaOcjena = 5;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _posaljiRecenziju({bool edit = false}) async {
    if (_komentarController.text.trim().isEmpty) return;
    if (AuthProvider.korisnikId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Morate biti prijavljeni da biste ostavili recenziju.")),
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
      if (_mojaRecenzija != null && _mojaRecenzija!.id != null) {
        await provider.update(_mojaRecenzija!.id!, recenzija);
      } else {
        await provider.insert(recenzija);
      }
      _komentarController.clear();
      _novaOcjena = 5;
      await _fetchRecenzije();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(edit ? "Recenzija uspješno izmijenjena!" : "Recenzija uspješno dodana!")),
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

  Future<void> _obrisiRecenziju() async {
    if (_mojaRecenzija == null) return;
    setState(() {
      _saljeSe = true;
    });
    try {
      final provider = Provider.of<RecenzijaProvider>(context, listen: false);
      if (_mojaRecenzija != null && _mojaRecenzija!.id != null) {
        await provider.delete(_mojaRecenzija!.id!);
      }
      _komentarController.clear();
      _novaOcjena = 5;
      await _fetchRecenzije();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recenzija obrisana!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Greška pri brisanju recenzije.")),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Card(
                              color: Colors.blue[50],
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 32),
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
                                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Dodaj/uredi svoju recenziju",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text("Ocjena:", style: TextStyle(fontSize: 15)),
                                        const SizedBox(width: 10),
                                        for (int i = 1; i <= 5; i++)
                                          IconButton(
                                            icon: Icon(
                                              i <= _novaOcjena ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                            ),
                                            onPressed: _saljeSe
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
                                      enabled: !_saljeSe && (_mojaRecenzija == null || _mojaRecenzija != null),
                                      maxLines: 3,
                                      maxLength: 300,
                                      decoration: const InputDecoration(
                                        labelText: "Komentar",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_mojaRecenzija != null)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.save),
                                              label: const Text("Izmijeni recenziju"),
                                              onPressed: _saljeSe
                                                  ? null
                                                  : () => _posaljiRecenziju(edit: true),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.delete),
                                            label: const Text("Obriši"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: _saljeSe ? null : _obrisiRecenziju,
                                          ),
                                        ],
                                      )
                                    else
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.send),
                                          label: const Text("Pošalji recenziju"),
                                          onPressed: _saljeSe
                                              ? null
                                              : (_mojaRecenzija != null
                                                  ? null
                                                  : _posaljiRecenziju),
                                        ),
                                      ),
                                    if (_mojaRecenzija != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          "Već ste komentarisali ovaj film. Možete urediti ili obrisati svoju recenziju.",
                                          style: TextStyle(color: Colors.blue[700], fontSize: 13),
                                        ),
                                      ),
                                    if (_mojaRecenzija == null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          "",
                                          style: TextStyle(color: Colors.blue[700], fontSize: 13),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 350,
                              child: _recenzije.isEmpty
                                  ? const Center(child: Text("Nema recenzija za ovaj film."))
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _recenzije.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                                      itemBuilder: (context, index) {
                                        final r = _recenzije[index];
                                        final korisnik = r.korisnikId != null ? _korisniciRecenzija[r.korisnikId!] : null;
                                        final datum = r.datumIvrijeme != null
                                            ? DateFormat('dd.MM.yyyy. HH:mm').format(r.datumIvrijeme!)
                                            : "";

                                        bool isObrisan = korisnik?.obrisan == true;

                                        ImageProvider? imageProvider;
                                        if (isObrisan) {
                                          imageProvider = null;
                                        } else if (korisnik?.slikaBase64 != null && korisnik!.slikaBase64!.isNotEmpty) {
                                          try {
                                            final base64Str = korisnik.slikaBase64!.contains(',')
                                                ? korisnik.slikaBase64!.split(',').last
                                                : korisnik.slikaBase64!;
                                            imageProvider = MemoryImage(base64Decode(base64Str));
                                          } catch (e) {
                                            imageProvider = null;
                                          }
                                        }

                                        final isMyReview = r.korisnikId == AuthProvider.korisnikId;

                                        return Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor: isObrisan ? Colors.red[100] : Colors.blue[100],
                                                  backgroundImage: imageProvider,
                                                  child: isObrisan
                                                      ? Icon(Icons.person_off, size: 28, color: Colors.red)
                                                      : (imageProvider == null
                                                          ? Icon(Icons.person, size: 28, color: Colors.blue)
                                                          : null),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          isObrisan
                                                            ? Text(
                                                                "Obrisan nalog",
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                  color: Colors.red,
                                                                ),
                                                              )
                                                            : Text(
                                                                "${korisnik?.ime ?? "Obrisan nalog"} ${korisnik?.prezime ?? ""}",
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                          const SizedBox(width: 8),
                                                          Icon(Icons.star, color: Colors.amber, size: 18),
                                                          Text(
                                                            "${r.ocjena ?? "-"}",
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          if (isMyReview)
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 8.0),
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.blue[100],
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: const Text(
                                                                  "Vaša recenzija",
                                                                  style: TextStyle(
                                                                    color: Colors.blue,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      if (datum.isNotEmpty)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 2.0, bottom: 6),
                                                          child: Text(
                                                            datum,
                                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                                          ),
                                                        ),
                                                      Text(
                                                        r.komentar ?? "",
                                                        style: const TextStyle(fontSize: 15),
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
                    ),
                  );
                },
              ),
            ),
    );
  }
}