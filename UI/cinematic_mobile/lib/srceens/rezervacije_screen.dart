import 'dart:convert';
import 'package:cinematic_mobile/models/rezervacija_film_dto.dart';
import 'package:cinematic_mobile/models/sjediste.dart';
import 'package:cinematic_mobile/models/hrana_pice.dart';
import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:cinematic_mobile/providers/rezervacija_provider.dart';
import 'package:cinematic_mobile/providers/sjediste_provider.dart';
import 'package:cinematic_mobile/providers/hranaPice_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RezervacijeScreen extends StatefulWidget {
  const RezervacijeScreen({super.key});

  @override
  State<RezervacijeScreen> createState() => _RezervacijeScreenState();
}

class _RezervacijeScreenState extends State<RezervacijeScreen> {
  bool prikaziAktivne = true;
  List<RezervacijaFilmDTO> aktivne = [];
  List<RezervacijaFilmDTO> prethodne = [];
  bool _isLoading = true;

  final Map<int, List<Sjediste>> _sjedistaMap = {};
  final Map<int, List<HranaPice>> _hranaPiceMap = {};

  @override
  void initState() {
    super.initState();
    _fetchRezervacije();
  }

  String _formatDatum(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('d.M.yyyy.').format(date);
  }

  String _formatVrijeme(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('HH:mm').format(date);
  }

  String _formatCijena(double? cijena) {
    if (cijena == null) return '-';
    return "${cijena.toStringAsFixed(2)} KM";
  }

  String _formatHranaPiceSaKolicinama(
    RezervacijaFilmDTO r,
    List<HranaPice> hranaPice,
  ) {
    if (hranaPice.isEmpty) return '-';
    if (r.kolicine == null || r.kolicine!.isEmpty) {
      return hranaPice.map((h) => h.naziv ?? '').join(', ');
    }
    List<String> result = [];
    for (int i = 0; i < hranaPice.length; i++) {
      final naziv = hranaPice[i].naziv ?? '';
      final kolicina = (i < (r.kolicine?.length ?? 0)) ? r.kolicine![i] : 1;
      result.add("$naziv x$kolicina");
    }
    return result.join(', ');
  }

  Future<void> _fetchRezervacije() async {
    setState(() => _isLoading = true);
    final rezervacijaProvider = Provider.of<RezervacijaProvider>(
      context,
      listen: false,
    );
    final sjedisteProvider = Provider.of<SjedisteProvider>(
      context,
      listen: false,
    );
    final hranaPiceProvider = Provider.of<HranaPiceProvider>(
      context,
      listen: false,
    );
    final korisnikId = AuthProvider.korisnikId;
    if (korisnikId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final sve = await rezervacijaProvider.getRezervacijeKorisnika(korisnikId);
    final sada = DateTime.now();
    aktivne =
        sve
            .where(
              (r) =>
                  r.datumProjekcije != null && r.datumProjekcije!.isAfter(sada),
            )
            .toList();
    prethodne =
        sve
            .where(
              (r) =>
                  r.datumProjekcije != null &&
                  r.datumProjekcije!.isBefore(sada),
            )
            .toList();

    for (var r in sve) {
      if (r.sjedistaIds != null && r.sjedistaIds!.isNotEmpty) {
        final sjedista = await Future.wait(
          r.sjedistaIds!.map((id) => sjedisteProvider.getById(id)),
        );
        _sjedistaMap[r.rezervacijaId ?? 0] = sjedista;
      } else {
        _sjedistaMap[r.rezervacijaId ?? 0] = [];
      }
      if (r.hranaPiceIds != null && r.hranaPiceIds!.isNotEmpty) {
        final hranaPice = await Future.wait(
          r.hranaPiceIds!.map((id) => hranaPiceProvider.getById(id)),
        );
        _hranaPiceMap[r.rezervacijaId ?? 0] = hranaPice;
      } else {
        _hranaPiceMap[r.rezervacijaId ?? 0] = [];
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _obrisiRezervaciju(int rezervacijaId) async {
    final rezervacijaProvider = Provider.of<RezervacijaProvider>(
      context,
      listen: false,
    );
    setState(() => _isLoading = true);
    try {
      await rezervacijaProvider.delete(rezervacijaId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rezervacija je uspješno obrisana.")),
      );
      await _fetchRezervacije();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška pri brisanju: $e")));
      setState(() => _isLoading = false);
    }
  }

  void _prikaziQrDialog(String? qrBase64) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("QR kod rezervacije"),
        content: qrBase64 != null
            ? Image.memory(base64Decode(qrBase64))
            : const Text("QR kod nije dostupan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Zatvori"),
          ),
        ],
      ),
    );
  }

  void _potvrdiBrisanje(int rezervacijaId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Potvrda brisanja"),
            content: const Text(
              "Da li ste sigurni da želite obrisati ovu rezervaciju?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Otkaži"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _obrisiRezervaciju(rezervacijaId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Obriši"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prikaz = prikaziAktivne ? aktivne : prethodne;
    return Scaffold(
      appBar: AppBar(title: const Text("Moje rezervacije")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => prikaziAktivne = true),
                        child: Container(
                          color: prikaziAktivne ? Colors.blue[100] : Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "Aktivne rezervacije",
                              style: TextStyle(
                                fontWeight: prikaziAktivne ? FontWeight.bold : FontWeight.normal,
                                color: prikaziAktivne ? Colors.blue : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => prikaziAktivne = false),
                        child: Container(
                          color: !prikaziAktivne ? Colors.blue[100] : Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "Prethodne rezervacije",
                              style: TextStyle(
                                fontWeight: !prikaziAktivne ? FontWeight.bold : FontWeight.normal,
                                color: !prikaziAktivne ? Colors.blue : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Expanded(
                  child: prikaz.isEmpty
                      ? Center(
                          child: Text(
                            prikaziAktivne
                                ? "Trenutno nemate aktivnih rezervacija."
                                : "Nemate prethodnih rezervacija.",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: prikaz.length,
                          itemBuilder: (context, index) {
                            final r = prikaz[index];
                            final sjedista = _sjedistaMap[r.rezervacijaId ?? 0] ?? [];
                            final hranaPice = _hranaPiceMap[r.rezervacijaId ?? 0] ?? [];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        r.filmaSlikaBase64 != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.memory(
                                                  base64Decode(r.filmaSlikaBase64!),
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[50],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.movie, size: 40, color: Colors.blue),
                                              ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            r.nazivFilma ?? "Film",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Text("Datum: ${_formatDatum(r.datumProjekcije)}"),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Text("Vrijeme: ${_formatVrijeme(r.datumProjekcije)}"),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.payment, size: 18, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Text("Način plaćanja: ${r.nacinPlacanja ?? '-'}"),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.attach_money, size: 18, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Text("Ukupna cijena: ${_formatCijena(r.ukupnaCijena)}"),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.event_seat, size: 18, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Sjedista: ${sjedista.isNotEmpty ? sjedista.map((s) => s.naziv ?? '').join(', ') : '-'}"
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.fastfood, size: 18, color: Colors.blueGrey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Hrana i piće: ${_formatHranaPiceSaKolicinama(r, hranaPice)}",
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (prikaziAktivne)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.qr_code, color: Colors.white),
                                              label: const Text("Prikaži QR kod"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () => _prikaziQrDialog(r.qrCodeBase64),
                                            ),
                                            const SizedBox(width: 12),
                                            if ((r.nacinPlacanja?.toLowerCase() ?? '') != 'stripe')
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.delete, color: Colors.white),
                                                label: const Text("Obriši"),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => _potvrdiBrisanje(r.rezervacijaId ?? 0),
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
    );
  }
}