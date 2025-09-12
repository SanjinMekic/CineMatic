import 'package:cinematic_desktop/models/recenzija.dart';
import 'package:cinematic_desktop/providers/recenzija_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRecenzije();
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

  Future<void> _obrisiRecenziju(int id) async {
    final provider = context.read<RecenzijaProvider>();
    try {
      await provider.delete(id);
      _loadRecenzije();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _recenzije.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final r = _recenzije[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(r.ocjena?.toString() ?? "-"),
                        backgroundColor: Colors.blue[100],
                      ),
                      title: Text(r.korisnik?.korisnickoIme ?? "Nepoznat korisnik"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (r.komentar != null && r.komentar!.isNotEmpty)
                            Text(r.komentar!),
                          if (r.datumIvrijeme != null)
                            Text(
                              DateFormat('dd.MM.yyyy. HH:mm').format(r.datumIvrijeme!),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (r.ocjena != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                r.ocjena!,
                                (i) => Icon(Icons.star, color: Colors.amber, size: 18),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: "Obriši recenziju",
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
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}