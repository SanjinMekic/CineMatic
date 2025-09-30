import 'dart:convert';
import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/models/film.dart';
import 'package:cinematic_mobile/models/preporuceni_film.dart';
import 'package:cinematic_mobile/providers/film_provider.dart';
import 'package:cinematic_mobile/providers/projekcija_provider.dart';
import 'package:cinematic_mobile/srceens/rezervisi_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'osoba_detalji_screen.dart';
import 'recenzije_screen.dart';

class ProjekcijaDetaljiScreen extends StatefulWidget {
  final Projekcija projekcija;
  final int? filmId;

  const ProjekcijaDetaljiScreen({
    super.key,
    required this.projekcija,
    this.filmId,
  });

  @override
  State<ProjekcijaDetaljiScreen> createState() => _ProjekcijaDetaljiScreenState();
}

class _ProjekcijaDetaljiScreenState extends State<ProjekcijaDetaljiScreen> {
  Film? _filmDetalji;
  List<Projekcija> _projekcijeZaFilm = [];
  bool _isLoading = true;

  // Dodaj za preporuke
  List<PreporuceniFilm> _preporuceniFilmovi = [];
  bool _preporukeLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFilmDetaljiIProjekcije();
    _fetchPreporuke();
  }

  Future<void> _fetchFilmDetaljiIProjekcije() async {
    final filmId = widget.filmId ?? widget.projekcija.filmId ?? widget.projekcija.film?.id;
    if (filmId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final filmProvider = Provider.of<FilmProvider>(context, listen: false);
    final projekcijaProvider = Provider.of<ProjekcijaProvider>(context, listen: false);

    final film = await filmProvider.getById(filmId);
    final projekcije = await projekcijaProvider.getByFilm(filmId);

    setState(() {
      _filmDetalji = film;
      _projekcijeZaFilm = projekcije.where((p) {
        final isActive = p.stanje?.toLowerCase() == "active" || p.stanje?.toLowerCase() == "aktivna";
        final isFuture = p.datumIvrijeme == null || p.datumIvrijeme!.isAfter(DateTime.now());
        return isActive && isFuture;
      }).toList();
      _isLoading = false;
    });
  }

  Future<void> _fetchPreporuke() async {
    try {
      print('Pozivam _fetchPreporuke');
      final filmProvider = Provider.of<FilmProvider>(context, listen: false);
      final filmId = widget.filmId ?? widget.projekcija.filmId ?? widget.projekcija.film?.id;
      print('filmId: $filmId');
      if (filmId != null) {
        final preporuke = await filmProvider.getRecommendations(filmId);
        print('Preporuke: $preporuke');
        setState(() {
          _preporuceniFilmovi = preporuke;
          _preporukeLoading = false;
        });
      }
    } catch (e, stack) {
      print('Greška u _fetchPreporuke: $e');
      print(stack);
      setState(() {
        _preporukeLoading = false;
      });
    }
  }

  Future<bool?> _showDobnaRestrikcijaDialog(BuildContext context, Projekcija projekcija) async {
    final film = _filmDetalji ?? widget.projekcija.film;
    final dobna = film?.dobnaRestrikcija;
    final restrikcijaText = dobna != null
        ? "${dobna.restrikcija ?? ''} - ${dobna.opis ?? ''}"
        : "Nema dobne restrikcije za ovaj film.";

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dobna restrikcija"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.child_care, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              restrikcijaText,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            const Text(
              "Molimo da potvrdite da ste upoznati sa dobnom restrikcijom za ovaj film.",
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
  TextButton(
    onPressed: () => Navigator.of(context).pop(false),
    child: const Text(
      "Odustani",
      style: TextStyle(color: Colors.red), // crvena boja teksta
    ),
  ),
  ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // plava boja kao dugme Recenzije
      foregroundColor: Colors.white,
    ),
    onPressed: () => Navigator.of(context).pop(true),
    child: const Text("Prihvatam"),
  ),
],
      ),
    );
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
              height: 42,
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

  Widget _projekcijaDetaljiCard(Projekcija projekcija) {
    String? datumStr;
    String? vrijemeStr;
    if (projekcija.datumIvrijeme != null) {
      final dt = projekcija.datumIvrijeme!;
      datumStr = DateFormat('dd.MM.yyyy.').format(dt);
      vrijemeStr = DateFormat('HH:mm').format(dt);
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if (projekcija.sala?.naziv != null)
              ListTile(
                leading: const Icon(Icons.event_seat),
                title: const Text("Sala"),
                subtitle: Text(projekcija.sala!.naziv!),
              ),
            if (projekcija.nacinProjekcije != null)
              ListTile(
                leading: const Icon(Icons.theaters),
                title: const Text("Tehnologija"),
                subtitle: Text(projekcija.nacinProjekcije!.naziv ?? ""),
              ),
            if (projekcija.cijena != null)
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text("Cijena"),
                subtitle: Text("${projekcija.cijena} KM"),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.event_available),
                label: const Text("Rezerviši"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final prihvaceno = await _showDobnaRestrikcijaDialog(context, projekcija);
                  if (prihvaceno == true) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RezervisiScreen(projekcija: projekcija),
                      ),
                    );
                  }
                  // Ako nije prihvaćeno, samo se zatvori dijalog
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreporuceniFilmCard(PreporuceniFilm film) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProjekcijaDetaljiScreen(
              projekcija: widget.projekcija,
              filmId: film.id,
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: 180,
          height: 230,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              film.imageBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        base64Decode(film.imageBase64!),
                        width: 152,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 152,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.movie, size: 48),
                    ),
              const SizedBox(height: 14),
              Flexible(
                child: Text(
                  film.naslov,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  if (film?.dobnaRestrikcija != null)
                    ListTile(
                      leading: const Icon(Icons.child_care),
                      title: const Text("Dobna restrikcija"),
                      subtitle: Text(
                        "${film!.dobnaRestrikcija?.restrikcija ?? ''} - ${film.dobnaRestrikcija?.opis ?? ''}",
                      ),
                    ),
                    if (film?.trajanje != null)
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text("Trajanje"),
                      subtitle: Text("${film!.trajanje} min"),
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
                  const SizedBox(height: 18),
                  const Divider(thickness: 2),
                  const SizedBox(height: 10),
                  const Text(
                    "Sve aktivne projekcije za ovaj film",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  _projekcijeZaFilm.isEmpty
                      ? const Text("Nema dostupnih aktivnih projekcija za ovaj film.")
                      : Column(
                          children: _projekcijeZaFilm
                              .map((p) => _projekcijaDetaljiCard(p))
                              .toList(),
                        ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.reviews, color: Colors.white),
                      label: const Text("Recenzije"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                  // --- PREPORUKE ---
                  const SizedBox(height: 32),
                  if (_preporukeLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_preporuceniFilmovi.isNotEmpty) ...[
                    const Text(
                      "Preporučujemo za vas",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _preporuceniFilmovi.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final f = _preporuceniFilmovi[index];
                          return _buildPreporuceniFilmCard(f);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}