import 'dart:convert';
import 'package:cinematic_mobile/models/glumac.dart';
import 'package:cinematic_mobile/models/reziser.dart';
import 'package:cinematic_mobile/providers/glumac_provider.dart';
import 'package:cinematic_mobile/providers/reziser_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum OsobaTip { glumac, reziser }

class OsobaDetaljiScreen extends StatefulWidget {
  final int osobaId;
  final OsobaTip tip;
  const OsobaDetaljiScreen({super.key, required this.osobaId, required this.tip});

  @override
  State<OsobaDetaljiScreen> createState() => _OsobaDetaljiScreenState();
}

class _OsobaDetaljiScreenState extends State<OsobaDetaljiScreen> {
  Glumac? _glumac;
  Reziser? _reziser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetalji();
  }

  Future<void> _fetchDetalji() async {
    if (widget.tip == OsobaTip.glumac) {
      final provider = Provider.of<GlumacProvider>(context, listen: false);
      final glumac = await provider.getById(widget.osobaId);
      setState(() {
        _glumac = glumac;
        _isLoading = false;
      });
    } else {
      final provider = Provider.of<ReziserProvider>(context, listen: false);
      final reziser = await provider.getById(widget.osobaId);
      setState(() {
        _reziser = reziser;
        _isLoading = false;
      });
    }
  }

  void _prikaziVelikuSliku(String? slikaBase64) {
  if (slikaBase64 == null) return;
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(201),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                base64Decode(slikaBase64),
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.8,
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.close, color: Colors.white, size: 32),
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
    String ime = "";
    String prezime = "";
    String opis = "";
    String? slikaBase64;
    String? datumRodjenja;
    String? uspjesi;
    String? ulogeUfilmovima;
    String? rezisiraniFilmovi;

    if (widget.tip == OsobaTip.glumac && _glumac != null) {
      ime = _glumac!.ime ?? "";
      prezime = _glumac!.prezime ?? "";
      opis = _glumac!.opis ?? "";
      slikaBase64 = _glumac!.slikaBase64;
      datumRodjenja = _glumac!.datumRodjenja != null
          ? DateFormat('dd.MM.yyyy.').format(_glumac!.datumRodjenja!)
          : null;
      uspjesi = _glumac!.uspjesi;
      ulogeUfilmovima = _glumac!.ulogeUfilmovima;
    } else if (widget.tip == OsobaTip.reziser && _reziser != null) {
      ime = _reziser!.ime ?? "";
      prezime = _reziser!.prezime ?? "";
      opis = _reziser!.opis ?? "";
      slikaBase64 = _reziser!.slikaBase64;
      datumRodjenja = _reziser!.datumRodjenja != null
          ? DateFormat('dd.MM.yyyy.').format(_reziser!.datumRodjenja!)
          : null;
      uspjesi = _reziser!.uspjesi;
      rezisiraniFilmovi = _reziser!.rezisiraniFilmovi;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tip == OsobaTip.glumac ? "Detalji glumca" : "Detalji režisera"),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (slikaBase64 != null) {
                          _prikaziVelikuSliku(slikaBase64);
                        }
                      },
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withAlpha(51),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: Colors.blueAccent, width: 3),
                        ),
                        child: ClipOval(
                          child: slikaBase64 != null
                              ? Image.memory(
                                  base64Decode(slikaBase64),
                                  fit: BoxFit.cover,
                                  width: 160,
                                  height: 160,
                                )
                              : Container(
                                  color: Colors.blue[50],
                                  child: const Icon(Icons.person, size: 90, color: Colors.blue),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "$ime $prezime",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (datumRodjenja != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cake, size: 22, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          datumRodjenja,
                          style: const TextStyle(fontSize: 17, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),
                  if (opis.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        opis,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (uspjesi != null && uspjesi.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Nagrade i uspjesi",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      color: Colors.amber[50],
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                uspjesi,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (widget.tip == OsobaTip.glumac && ulogeUfilmovima != null && ulogeUfilmovima.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Uloge u filmovima",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      color: Colors.blue[50],
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.movie, color: Colors.blue, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ulogeUfilmovima,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (widget.tip == OsobaTip.reziser && rezisiraniFilmovi != null && rezisiraniFilmovi.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Režisirani filmovi",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      color: Colors.green[50],
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.video_library, color: Colors.green, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rezisiraniFilmovi,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}