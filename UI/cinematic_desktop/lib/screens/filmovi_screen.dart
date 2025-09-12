import 'dart:convert';
import 'package:cinematic_desktop/models/film.dart';
import 'package:cinematic_desktop/providers/film_provider.dart';
import 'package:cinematic_desktop/screens/dodaj_film_screen.dart';
import 'package:cinematic_desktop/screens/recenzije_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilmoviScreen extends StatefulWidget {
  const FilmoviScreen({super.key});

  @override
  State<FilmoviScreen> createState() => _FilmoviScreenState();
}

class _FilmoviScreenState extends State<FilmoviScreen> {
  late FilmProvider _filmProvider;
  List<Film> _filmovi = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filmProvider = context.read<FilmProvider>();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final filter = {
      "isDobneRestrikcijeIncluded": true,
      "isGlumciIncluded": true,
      "isRežiseriIncluded": true,
      "isŽanroviIncluded": true,
      "NazivGTE": _searchController.text,
    };
    final result = await _filmProvider.get(filter: filter);
    setState(() {
      _filmovi = result.result;
      _isLoading = false;
    });
  }

  Future<void> _deleteFilm(Film film) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potvrda brisanja"),
        content: Text(
          "Da li ste sigurni da želite obrisati film \"${film.naziv ?? ""}\"?",
        ),
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
    if (confirm == true) {
      await _filmProvider.delete(film.id!);
      _loadData();
    }
  }

  void _onSearch() {
    _loadData();
  }

  Widget _buildImage(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.movie, color: Colors.grey, size: 64),
      );
    }
    try {
      final bytes = base64Decode(base64);
      if (bytes.isEmpty) throw Exception("Empty bytes");
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          bytes,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 180,
              color: Colors.grey[200],
              child: Icon(Icons.movie, color: Colors.grey, size: 64),
            );
          },
        ),
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: 180,
        color: Colors.grey[200],
        child: Icon(Icons.movie, color: Colors.grey, size: 64),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          "Dodaj film",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 18),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DodajFilmScreen()),
                        );
                        if (result == true) _loadData();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: "Pretraži po nazivu filma",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _onSearch,
                        child: Text("Pretraži"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filmovi.isEmpty
                        ? Center(child: Text("Nema filmova."))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 1;
                              if (constraints.maxWidth > 1200) {
                                crossAxisCount = 3;
                              } else if (constraints.maxWidth > 800) {
                                crossAxisCount = 2;
                              }
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: _filmovi.length,
                                itemBuilder: (context, index) {
                                  final film = _filmovi[index];
                                  return Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          _buildImage(film.slikaBase64),
                                          const SizedBox(height: 12),
                                          Text(
                                            film.naziv ?? "",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey[900],
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          if (film.trajanje != null)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.timer, size: 18, color: Colors.grey[700]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${film.trajanje} min",
                                                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                                                ),
                                              ],
                                            ),
                                          if (film.opis != null && film.opis!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.description, size: 18, color: Colors.grey[700]),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      film.opis!,
                                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (film.dobnaRestrikcija?.restrikcija != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.no_adult_content, size: 18, color: Colors.red[400]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Dobna restrikcija: ${film.dobnaRestrikcija!.restrikcija}",
                                                    style: TextStyle(fontSize: 15, color: Colors.red[400]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (film.zanrs != null && film.zanrs!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.category, size: 18, color: Colors.orange[700]),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      "Žanrovi: ${film.zanrs!.map((z) => z.naziv).join(', ')}",
                                                      style: TextStyle(fontSize: 15, color: Colors.orange[800]),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (film.glumacs != null && film.glumacs!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.people, size: 18, color: Colors.blue[700]),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      "Glumci: ${film.glumacs!.map((g) => "${g.ime} ${g.prezime}").join(', ')}",
                                                      style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (film.rezisers != null && film.rezisers!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.person, size: 18, color: Colors.green[700]),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      "Režiseri: ${film.rezisers!.map((r) => "${r.ime} ${r.prezime}").join(', ')}",
                                                      style: TextStyle(fontSize: 14, color: Colors.green[800]),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const Spacer(),
                                          Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Tooltip(
                                                message: "Recenzije",
                                                child: IconButton(
                                                  icon: Icon(Icons.rate_review, color: Colors.orange),
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => RecenzijeScreen(
                                                          filmId: film.id!,
                                                          filmNaziv: film.naziv,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Tooltip(
                                                message: "Uredi",
                                                child: IconButton(
                                                  icon: Icon(Icons.edit, color: Colors.blue),
                                                  onPressed: () async {
                                                    final result = await Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => DodajFilmScreen(film: film),
                                                      ),
                                                    );
                                                    if (result == true) _loadData();
                                                  },
                                                ),
                                              ),
                                              Tooltip(
                                                message: "Obriši",
                                                child: IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _deleteFilm(film),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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