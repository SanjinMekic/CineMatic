import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/models/sjediste_dto.dart';
import 'package:cinematic_mobile/providers/projekcija_provider.dart';
import 'package:cinematic_mobile/srceens/odabir_hrana_pice_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RezervisiScreen extends StatefulWidget {
  final Projekcija projekcija;
  const RezervisiScreen({super.key, required this.projekcija});

  @override
  State<RezervisiScreen> createState() => _RezervisiScreenState();
}

class _RezervisiScreenState extends State<RezervisiScreen> {
  List<SjedisteDTO> _sjedista = [];
  Set<int> _odabranaSjedista = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSjedista();
  }

  Future<void> _fetchSjedista() async {
    final provider = Provider.of<ProjekcijaProvider>(context, listen: false);
    final sjedista = await provider.getSjedista(widget.projekcija.id!);
    setState(() {
      _sjedista = sjedista;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<SjedisteDTO>> redovi = {};
    for (var s in _sjedista) {
      final red = (s.naziv != null && s.naziv!.isNotEmpty) ? s.naziv![0] : "?";
      redovi.putIfAbsent(red, () => []).add(s);
    }
    final sortedRedovi = redovi.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Odaberi sjedišta"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        "EKRAN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: sortedRedovi.map((red) {
                          final sjedistaURedu = redovi[red]!;
                          sjedistaURedu.sort((a, b) => (a.naziv ?? '').compareTo(b.naziv ?? ''));
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: sjedistaURedu.map((sjediste) {
                                final isZauzeto = sjediste.rezervisano;
                                final isOdabrano = _odabranaSjedista.contains(sjediste.id);
                                return GestureDetector(
                                  onTap: isZauzeto
                                      ? null
                                      : () {
                                          setState(() {
                                            if (isOdabrano) {
                                              _odabranaSjedista.remove(sjediste.id);
                                            } else {
                                              _odabranaSjedista.add(sjediste.id);
                                            }
                                          });
                                        },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isZauzeto
                                          ? Colors.red
                                          : isOdabrano
                                              ? Colors.green
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isOdabrano ? Colors.black : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: isOdabrano
                                          ? const Icon(Icons.close, color: Colors.white)
                                          : Text(
                                              sjediste.naziv ?? '',
                                              style: TextStyle(
                                                color: isZauzeto ? Colors.white : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Rezerviši odabrana sjedišta"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _odabranaSjedista.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HranaPiceScreen(
                                    projekcija: widget.projekcija,
                                    odabranaSjedistaId: _odabranaSjedista.toList(),
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