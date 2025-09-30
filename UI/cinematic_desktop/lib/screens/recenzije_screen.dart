import 'package:cinematic_desktop/models/recenzija.dart';
import 'package:cinematic_desktop/providers/recenzija_provider.dart';
import 'package:cinematic_desktop/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class RecenzijeScreen extends StatefulWidget {
  final int filmId;
  final String? filmNaziv;
  const RecenzijeScreen({super.key, required this.filmId, this.filmNaziv});

  @override
  State<RecenzijeScreen> createState() => _RecenzijeScreenState();
}

class _RecenzijeScreenState extends State<RecenzijeScreen> {
  List<Recenzija> _recenzije = [];
  bool _isLoading = true;
  double? _averageRating;
  KorisnikProvider? _korisnikProvider;

  @override
  void initState() {
    super.initState();
    _korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
    _loadRecenzije();
    _loadAverageRating();
  }

  Future<void> _loadRecenzije() async {
    setState(() => _isLoading = true);
    final provider = context.read<RecenzijaProvider>();
    final result = await provider.getByFilm(widget.filmId);
    setState(() {
      _recenzije = result;
      _isLoading = false;
    });
  }

  Future<void> _loadAverageRating() async {
    final provider = context.read<RecenzijaProvider>();
    try {
      final avg = await provider.getAverageRating(widget.filmId);
      setState(() {
        _averageRating = avg;
      });
    } catch (_) {
      setState(() {
        _averageRating = null;
      });
    }
  }

  Future<void> _obrisiRecenziju(int id) async {
    final provider = context.read<RecenzijaProvider>();
    try {
      await provider.delete(id);
      await _loadRecenzije();
      await _loadAverageRating();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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

  Widget _buildAvatar(Recenzija r) {
    if (r.korisnik?.slikaBase64 != null && r.korisnik!.slikaBase64!.isNotEmpty) {
      try {
        return CircleAvatar(
          backgroundImage: MemoryImage(base64Decode(r.korisnik!.slikaBase64!)),
          radius: 28,
        );
      } catch (_) {
        return CircleAvatar(child: Icon(Icons.person), radius: 28);
      }
    }
    return CircleAvatar(child: Icon(Icons.person), radius: 28);
  }

  Widget _buildKorisnikNaslov(Recenzija r) {
    return FutureBuilder<dynamic>(
      future: _fetchKorisnikById(r.korisnik?.id, r.korisnik),
      builder: (context, snapshot) {
        final stvarniKorisnik = snapshot.data ?? r.korisnik;
        final osnovni = stvarniKorisnik?.korisnickoIme ?? "Nepoznat korisnik";
        if (stvarniKorisnik?.obrisan == true) {
          return Row(
            children: [
              Text(
                osnovni,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(width: 8),
              Text(
                "- Obrisan nalog",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        } else {
          return Text(
            osnovni,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          );
        }
      },
    );
  }

  Widget _buildAverageRating() {
    if (_averageRating == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: [
          Text(
            "Prosječna ocjena: ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...List.generate(
            _averageRating!.round(),
            (i) => Icon(Icons.star, color: Colors.amber, size: 22),
          ),
          const SizedBox(width: 8),
          Text(
            _averageRating!.toStringAsFixed(2),
            style: TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recenzije za film: ${widget.filmNaziv ?? ""}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recenzije.isEmpty
              ? Center(child: Text("Nema recenzija za ovaj film."))
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAverageRating(),
                      Expanded(
  child: ListView.separated(
    itemCount: _recenzije.length,
    separatorBuilder: (_, __) => SizedBox(height: 18),
    itemBuilder: (context, index) {
      final r = _recenzije[index];
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(r),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.ocjena != null)
                      Row(
                        children: List.generate(
                          r.ocjena!,
                          (i) => Icon(Icons.star, color: Colors.amber, size: 20),
                        ),
                      ),
                    _buildKorisnikNaslov(r),
                    if (r.komentar != null && r.komentar!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          r.komentar!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    if (r.datumIvrijeme != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          DateFormat('dd.MM.yyyy. HH:mm').format(r.datumIvrijeme!),
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Tooltip(
                    message: "Obriši recenziju",
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final potvrdi = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Potvrda brisanja"),
                            content: Text("Da li ste sigurni da želite obrisati ovu recenziju?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("Otkaži"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text("Obriši", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (potvrdi == true) {
                          await _obrisiRecenziju(r.id!);
                        }
                      },
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
),
                    ],
                  ),
                ),
    );
  }
}