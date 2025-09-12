import 'package:cinematic_desktop/models/rezervacija.dart';
import 'package:cinematic_desktop/providers/rezervacija_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RezervacijeScreen extends StatefulWidget {
  final int projekcijaId;
  const RezervacijeScreen({super.key, required this.projekcijaId});

  @override
  State<RezervacijeScreen> createState() => _RezervacijeScreenState();
}

class _RezervacijeScreenState extends State<RezervacijeScreen> {
  List<Rezervacija> _rezervacije = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRezervacije();
  }

  Future<void> _fetchRezervacije() async {
    setState(() => _isLoading = true);
    final provider = context.read<RezervacijaProvider>();
    final result = await provider.getByProjekcija(widget.projekcijaId);
    setState(() {
      _rezervacije = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rezervacije")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rezervacije.isEmpty
              ? const Center(child: Text("Nema rezervacija za ovu projekciju."))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemCount: _rezervacije.length,
                  itemBuilder: (context, index) {
                    final r = _rezervacije[index];
                    final korisnik = r.korisnik;
                    final projekcija = r.projekcija;
                    final sjedista = r.rezervacijeSjedista
                        ?.map((s) => s.sjediste?.naziv ?? "")
                        .where((s) => s.isNotEmpty)
                        .join(", ");
                    final hranaPice = r.rezervacijeHraneIPica
                        ?.map((h) => h.hranaIPice?.naziv ?? "")
                        .where((h) => h.isNotEmpty)
                        .join(", ");
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Text(
                                  "${korisnik?.ime ?? ""} ${korisnik?.prezime ?? ""} (${korisnik?.korisnickoIme ?? ""})",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Text(
                                  r.datumIvrijeme != null
                                      ? DateFormat('dd.MM.yyyy. HH:mm').format(r.datumIvrijeme!)
                                      : "-",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.event_seat, size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Sjedista: ${sjedista ?? "-"}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.fastfood, size: 18, color: Colors.orange[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Hrana i piće: ${hranaPice?.isNotEmpty == true ? hranaPice : "-"}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.theaters, size: 18, color: Colors.purple[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Sala: ${projekcija?.sala?.naziv ?? "-"}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.screen_share, size: 18, color: Colors.green[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Tehnologija: ${projekcija?.nacinProjekcije?.naziv ?? "-"}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Cijena po karti: ${projekcija?.cijena?.toStringAsFixed(2) ?? "-"} KM",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.confirmation_number, size: 18, color: Colors.blue[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Broj ulaznica: ${r.brojUlaznica ?? "-"}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.payments, size: 18, color: Colors.teal[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Način plaćanja: ${r.nacinPlacanja ?? "-"}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.summarize, size: 18, color: Colors.red[700]),
                                const SizedBox(width: 6),
                                Text(
                                  "Ukupna cijena: ${r.ukupnaCijena?.toStringAsFixed(2) ?? "-"} KM",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}