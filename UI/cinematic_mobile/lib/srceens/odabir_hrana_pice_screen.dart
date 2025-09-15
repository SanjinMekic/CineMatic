import 'dart:convert';

import 'package:cinematic_mobile/models/hrana_pice.dart';
import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/providers/hranaPice_provider.dart';
import 'package:cinematic_mobile/srceens/finalna_rezervacija_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HranaPiceScreen extends StatefulWidget {
  final Projekcija projekcija;
  final List<int> odabranaSjedistaId;
  const HranaPiceScreen({
    super.key,
    required this.projekcija,
    required this.odabranaSjedistaId,
  });

  @override
  State<HranaPiceScreen> createState() => _HranaPiceScreenState();
}

class _HranaPiceScreenState extends State<HranaPiceScreen> {
  List<HranaPice> _artikli = [];
  Map<int, int> _kolicine = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtikle();
  }

  Future<void> _fetchArtikle() async {
    final provider = Provider.of<HranaPiceProvider>(context, listen: false);
    final result = await provider.get();
    setState(() {
      _artikli = result.result;
      _isLoading = false;
    });
  }

  void _promijeniKolicinu(int id, int delta) {
    setState(() {
      final trenutna = _kolicine[id] ?? 0;
      final nova = trenutna + delta;
      if (nova < 0) return;
      _kolicine[id] = nova;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hrana i piće"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _artikli.length,
                      itemBuilder: (context, index) {
                        final artikal = _artikli[index];
                        final kolicina = _kolicine[artikal.id] ?? 0;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: artikal.slikaBase64 != null
    ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode(artikal.slikaBase64!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      )
    : const Icon(Icons.fastfood, size: 32),
                            title: Text(artikal.naziv ?? ""),
                            subtitle: Text(
                              artikal.cijena != null
                                  ? "${artikal.cijena!.toStringAsFixed(2)} KM"
                                  : "",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: kolicina > 0
                                      ? () => _promijeniKolicinu(artikal.id, -1)
                                      : null,
                                ),
                                Text(
                                  kolicina.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _promijeniKolicinu(artikal.id, 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Potvrdi izbor"),
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
                        final odabranaHranaPica = _artikli.where((a) => (_kolicine[a.id] ?? 0) > 0).toList();
                        final kolicineHranePica = Map<int, int>.fromEntries(
                          _kolicine.entries.where((e) => e.value > 0),
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PregledRezervacijeScreen(
                              projekcija: widget.projekcija,
                              sjedistaIds: widget.odabranaSjedistaId,
                              odabranaHranaPica: odabranaHranaPica,
                              kolicineHranePica: kolicineHranePica,
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