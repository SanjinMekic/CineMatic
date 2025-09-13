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

  @override
Widget build(BuildContext context) {
  String ime = "";
  String prezime = "";
  String opis = "";
  String? slikaBase64;
  String? datumRodjenja;

  if (widget.tip == OsobaTip.glumac && _glumac != null) {
    ime = _glumac!.ime ?? "";
    prezime = _glumac!.prezime ?? "";
    opis = _glumac!.opis ?? "";
    slikaBase64 = _glumac!.slikaBase64;
    datumRodjenja = _glumac!.datumRodjenja != null
        ? DateFormat('dd.MM.yyyy.').format(_glumac!.datumRodjenja!)
        : null;
  } else if (widget.tip == OsobaTip.reziser && _reziser != null) {
    ime = _reziser!.ime ?? "";
    prezime = _reziser!.prezime ?? "";
    opis = _reziser!.opis ?? "";
    slikaBase64 = _reziser!.slikaBase64;
    datumRodjenja = _reziser!.datumRodjenja != null
        ? DateFormat('dd.MM.yyyy.').format(_reziser!.datumRodjenja!)
        : null;
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(widget.tip == OsobaTip.glumac ? "Detalji glumca" : "Detalji režisera"),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: slikaBase64 != null
                        ? MemoryImage(base64Decode(slikaBase64))
                        : null,
                    child: slikaBase64 == null
                        ? Icon(Icons.person, size: 60, color: Colors.blue)
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "$ime $prezime",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (datumRodjenja != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cake, size: 20, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        datumRodjenja,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                if (opis.isNotEmpty)
                  Text(
                    opis,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
  );
}
}