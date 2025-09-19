import 'package:cinematic_desktop/models/rezervacija.dart';
import 'package:cinematic_desktop/providers/rezervacija_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

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

  Widget _buildAvatar(dynamic korisnik) {
    if (korisnik?.slikaBase64 != null && korisnik.slikaBase64.isNotEmpty) {
      try {
        return CircleAvatar(
          backgroundImage: MemoryImage(base64Decode(korisnik.slikaBase64)),
          radius: 28,
        );
      } catch (_) {
        return CircleAvatar(child: Icon(Icons.person), radius: 28);
      }
    }
    return CircleAvatar(child: Icon(Icons.person), radius: 28);
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? iconColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatar(korisnik),
                            const SizedBox(width: 22),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${korisnik?.ime ?? ""} ${korisnik?.prezime ?? ""} (${korisnik?.korisnickoIme ?? ""})",
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Divider(),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    "Datum",
                                    r.datumIvrijeme != null
                                        ? DateFormat('dd.MM.yyyy. HH:mm').format(r.datumIvrijeme!)
                                        : "-",
                                  ),
                                  _buildInfoRow(
                                    Icons.event_seat,
                                    "Sjedista",
                                    sjedista ?? "-",
                                  ),
                                  _buildInfoRow(
                                    Icons.fastfood,
                                    "Hrana i piće",
                                    hranaPice?.isNotEmpty == true ? hranaPice! : "-",
                                    iconColor: Colors.orange[700],
                                  ),
                                  _buildInfoRow(
                                    Icons.theaters,
                                    "Sala",
                                    projekcija?.sala?.naziv ?? "-",
                                    iconColor: Colors.purple[700],
                                  ),
                                  _buildInfoRow(
                                    Icons.screen_share,
                                    "Tehnologija",
                                    projekcija?.nacinProjekcije?.naziv ?? "-",
                                    iconColor: Colors.green[700],
                                  ),
                                  _buildInfoRow(
                                    Icons.attach_money,
                                    "Cijena po karti",
                                    "${projekcija?.cijena?.toStringAsFixed(2) ?? "-"} KM",
                                    iconColor: Colors.green[700],
                                  ),
                                  _buildInfoRow(
                                    Icons.confirmation_number,
                                    "Broj ulaznica",
                                    "${r.brojUlaznica ?? "-"}",
                                    iconColor: Colors.blue[700],
                                  ),
                                  _buildInfoRow(
                                    Icons.payments,
                                    "Način plaćanja",
                                    r.nacinPlacanja ?? "-",
                                    iconColor: Colors.teal[700],
                                  ),
                                  _buildInfoRow(
                                    Icons.summarize,
                                    "Ukupna cijena",
                                    "${r.ukupnaCijena?.toStringAsFixed(2) ?? "-"} KM",
                                    iconColor: Colors.red[700],
                                    bold: true,
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
    );
  }
}