import 'dart:convert';
import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/models/film.dart';
import 'package:cinematic_mobile/providers/film_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'osoba_detalji_screen.dart';
import 'recenzije_screen.dart';

class ProjekcijaDetaljiScreen extends StatefulWidget {
  final Projekcija projekcija;
  const ProjekcijaDetaljiScreen({super.key, required this.projekcija});

  @override
  State<ProjekcijaDetaljiScreen> createState() => _ProjekcijaDetaljiScreenState();
}

class _ProjekcijaDetaljiScreenState extends State<ProjekcijaDetaljiScreen> {
  Film? _filmDetalji;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFilmDetalji();
  }

  Future<void> _fetchFilmDetalji() async {
    final filmId = widget.projekcija.filmId ?? widget.projekcija.film?.id;
    if (filmId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final filmProvider = Provider.of<FilmProvider>(context, listen: false);
    final film = await filmProvider.getById(filmId);
    setState(() {
      _filmDetalji = film;
      _isLoading = false;
    });
  }

  Widget _buildCirclePerson({String? slikaBase64, required String ime, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.blue[100],
              backgroundImage: slikaBase64 != null
                  ? MemoryImage(base64Decode(slikaBase64))
                  : null,
              child: slikaBase64 == null
                  ? Icon(Icons.person, size: 32, color: Colors.blue)
                  : null,
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 42, // Dovoljno za dva reda teksta
              child: Center(
                child: Text(
                  ime,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? datumStr;
    String? vrijemeStr;
    if (widget.projekcija.datumIvrijeme != null) {
      final dt = widget.projekcija.datumIvrijeme!;
      datumStr = DateFormat('dd.MM.yyyy.').format(dt);
      vrijemeStr = DateFormat('HH:mm').format(dt);
    }

    final film = _filmDetalji ?? widget.projekcija.film;

    return Scaffold(
      appBar: AppBar(
        title: Text(film?.naziv ?? "Detalji projekcije"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  film?.slikaBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(film!.slikaBase64!),
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 220,
                          color: Colors.grey[300],
                          child: const Icon(Icons.movie, size: 60),
                        ),
                  const SizedBox(height: 18),
                  Text(
                    film?.naziv ?? "Nepoznat film",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  if (datumStr != null)
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text("Datum projekcije"),
                      subtitle: Text(datumStr),
                    ),
                  if (vrijemeStr != null)
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text("Vrijeme projekcije"),
                      subtitle: Text(vrijemeStr),
                    ),
                  if (widget.projekcija.sala?.naziv != null)
                    ListTile(
                      leading: const Icon(Icons.event_seat),
                      title: const Text("Sala"),
                      subtitle: Text(widget.projekcija.sala!.naziv!),
                    ),
                  if (widget.projekcija.nacinProjekcije != null)
                    ListTile(
                      leading: const Icon(Icons.theaters),
                      title: const Text("Tehnologija"),
                      subtitle: Text(widget.projekcija.nacinProjekcije!.naziv ?? ""),
                    ),
                  if (widget.projekcija.cijena != null)
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: const Text("Cijena"),
                      subtitle: Text("${widget.projekcija.cijena} KM"),
                    ),
                  if (film?.dobnaRestrikcija != null)
                    ListTile(
                      leading: const Icon(Icons.child_care),
                      title: const Text("Dobna restrikcija"),
                      subtitle: Text(
                        "${film!.dobnaRestrikcija?.restrikcija ?? ''} - ${film.dobnaRestrikcija?.opis ?? ''}",
                      ),
                    ),
                  if (film?.zanrs != null && film!.zanrs!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text("Žanrovi"),
                      subtitle: Text(
                        film.zanrs!.map((z) => z.naziv).join(', '),
                      ),
                    ),
                  if (film?.opis != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        film!.opis!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (film?.glumacs != null && film!.glumacs!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Glumci",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: film.glumacs!
                                .map((g) => Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _buildCirclePerson(
                                        slikaBase64: g.slikaBase64,
                                        ime: "${g.ime} ${g.prezime}",
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => OsobaDetaljiScreen(
                                                osobaId: g.id,
                                                tip: OsobaTip.glumac,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  if (film?.rezisers != null && film!.rezisers!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Režiseri",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: film.rezisers!
                                .map((r) => Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _buildCirclePerson(
                                        slikaBase64: r.slikaBase64,
                                        ime: "${r.ime} ${r.prezime}",
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => OsobaDetaljiScreen(
                                                osobaId: r.id,
                                                tip: OsobaTip.reziser,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event_available),
                      label: const Text("Rezerviši"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        // TODO: Implementirati rezervaciju
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.reviews, color: Colors.blue),
                      label: const Text("Recenzije", style: TextStyle(color: Colors.blue)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.blue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.blue,
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (film?.id != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RecenzijeScreen(filmId: film!.id!),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}