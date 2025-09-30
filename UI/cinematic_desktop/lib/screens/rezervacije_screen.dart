import 'package:cinematic_desktop/models/rezervacija.dart';
import 'package:cinematic_desktop/providers/rezervacija_provider.dart';
import 'package:cinematic_desktop/providers/korisnik_provider.dart';
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
  KorisnikProvider? _korisnikProvider;

  @override
  void initState() {
    super.initState();
    _korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
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

  Future<dynamic> _fetchKorisnikById(int? id, dynamic fallback) async {
    if (id == null) return fallback;
    try {
      final korisnik = await _korisnikProvider!.getById(id);
      return korisnik;
    } catch (_) {
      return fallback;
    }
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKorisnikNaslov(dynamic korisnik) {
    return FutureBuilder<dynamic>(
      future: _fetchKorisnikById(korisnik?.id, korisnik),
      builder: (context, snapshot) {
        final stvarniKorisnik = snapshot.data ?? korisnik;
        final osnovni =
            "${stvarniKorisnik?.ime ?? ""} ${stvarniKorisnik?.prezime ?? ""} (${stvarniKorisnik?.korisnickoIme ?? ""})";
        if (stvarniKorisnik?.obrisan == true) {
          return Row(
            children: [
              Text(
                osnovni,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "- Obrisan nalog",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        } else {
          return Text(
            osnovni,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }

  void _showQrDialog(String qrBase64) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("QR kod rezervacije"),
        content: qrBase64.isNotEmpty
            ? SizedBox(
                width: 320,
                height: 320,
                child: Image.memory(
                  base64Decode(qrBase64),
                  fit: BoxFit.contain,
                ),
              )
            : Text("QR kod nije dostupan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Zatvori"),
          ),
        ],
      ),
    );
  }

  String _formatHranaPiceSaKolicinama(List? rezervacijeHraneIPica) {
  if (rezervacijeHraneIPica == null || rezervacijeHraneIPica.isEmpty) return '-';
  Map<String, int> map = {};
  for (var h in rezervacijeHraneIPica) {
    final naziv = h.hranaIPice?.naziv?.toString() ?? '';
    final kolicina = (h.kolicina ?? 1);
    final kolicinaInt = kolicina is int ? kolicina : (kolicina as num).toInt();
    if (naziv.isNotEmpty) {
      map[naziv] = (map[naziv] ?? 0) + kolicinaInt;
    }
  }
  return map.entries.map((e) => "${e.key} x${e.value}").join(", ");
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
                    final hranaPice = _formatHranaPiceSaKolicinama(r.rezervacijeHraneIPica);
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
                                  _buildKorisnikNaslov(korisnik),
                                  const SizedBox(height: 10),
                                  Divider(),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    "Datum",
                                    r.datumIvrijeme != null
                                        ? DateFormat(
                                            'dd.MM.yyyy. HH:mm',
                                          ).format(r.datumIvrijeme!)
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
                                    hranaPice,
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
                                  _buildInfoRow(
                                    Icons.cancel,
                                    "Poništena karta",
                                    r.ponistenaKarta == true ? "DA" : "NE",
                                    iconColor: r.ponistenaKarta == true
                                        ? Colors.red
                                        : Colors.green,
                                    bold: r.ponistenaKarta == true,
                                  ),
                                  const SizedBox(height: 10),
                                  if (r.qrcodeBase64 != null &&
                                      r.qrcodeBase64!.isNotEmpty)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.qr_code),
                                        label: Text("Pogledaj QR kod"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed:
                                            () => _showQrDialog(r.qrcodeBase64!),
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
    );
  }
}