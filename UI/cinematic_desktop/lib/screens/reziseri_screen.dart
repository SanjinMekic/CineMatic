import 'dart:convert';
import 'package:cinematic_desktop/models/reziser.dart';
import 'package:cinematic_desktop/providers/reziser_provider.dart';
import 'package:cinematic_desktop/screens/reziser_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReziseriScreen extends StatefulWidget {
  const ReziseriScreen({super.key});

  @override
  State<ReziseriScreen> createState() => _ReziseriScreenState();
}

class _ReziseriScreenState extends State<ReziseriScreen> {
  List<Reziser> _reziseri = [];
  bool _isLoading = true;

  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  String? _imeFilter;
  String? _prezimeFilter;

  @override
  void initState() {
    super.initState();
    _fetchReziseri();
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    super.dispose();
  }

  Future<void> _fetchReziseri() async {
    final provider = Provider.of<ReziserProvider>(context, listen: false);
    final filter = {
      if (_imeFilter != null && _imeFilter!.isNotEmpty) 'imeGTE': _imeFilter,
      if (_prezimeFilter != null && _prezimeFilter!.isNotEmpty) 'prezimeGTE': _prezimeFilter,
    };
    final result = await provider.get(filter: filter);
    setState(() {
      _reziseri = result.result;
      _isLoading = false;
    });
  }

  Widget _buildImage(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return Container(
        width: 120,
        height: 160,
        color: Colors.grey[300],
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
    try {
      return Image.memory(
        base64Decode(base64),
        width: 120,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 160,
            color: Colors.grey[300],
            child: Icon(Icons.person, size: 60, color: Colors.grey),
          );
        },
      );
    } catch (_) {
      return Container(
        width: 120,
        height: 160,
        color: Colors.grey[300],
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
  }

  void _showReziserDetalji(Reziser reziser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: reziser.slikaBase64 != null && reziser.slikaBase64!.isNotEmpty
                  ? MemoryImage(base64Decode(reziser.slikaBase64!))
                  : null,
              child: (reziser.slikaBase64 == null || reziser.slikaBase64!.isEmpty)
                  ? Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "${reziser.ime ?? ''} ${reziser.prezime ?? ''}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reziser.datumRodjenja != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.cake, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Datum rođenja: ${reziser.datumRodjenja!.toLocal().toString().split(' ')[0]}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              if (reziser.opis != null && reziser.opis!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reziser.opis!,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              if (reziser.uspjesi != null && reziser.uspjesi!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Uspjesi:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            Text(
                              reziser.uspjesi!,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (reziser.rezisiraniFilmovi != null && reziser.rezisiraniFilmovi!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.movie, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Režisirani filmovi:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text(
                              reziser.rezisiraniFilmovi!,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Zatvori"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Filteri
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imeController,
                          decoration: InputDecoration(
                            labelText: "Pretraga po imenu",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _prezimeController,
                          decoration: InputDecoration(
                            labelText: "Pretraga po prezimenu",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.search),
                        label: Text("Pretraži"),
                        onPressed: () {
                          setState(() {
                            _imeFilter = _imeController.text.isNotEmpty ? _imeController.text : null;
                            _prezimeFilter = _prezimeController.text.isNotEmpty ? _prezimeController.text : null;
                            _isLoading = true;
                          });
                          _fetchReziseri();
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        child: Text("Reset"),
                        onPressed: () {
                          _imeController.clear();
                          _prezimeController.clear();
                          setState(() {
                            _imeFilter = null;
                            _prezimeFilter = null;
                            _isLoading = true;
                          });
                          _fetchReziseri();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Dodaj"),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReziserFormScreen(),
                            ),
                          );
                          if (result == true) _fetchReziseri();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _reziseri.length,
                      itemBuilder: (context, index) {
                        final reziser = _reziseri[index];
                        return GestureDetector(
                          onTap: () => _showReziserDetalji(reziser),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildImage(reziser.slikaBase64),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${reziser.ime ?? ''} ${reziser.prezime ?? ''}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.white),
                                          tooltip: "Uredi",
                                          onPressed: () async {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            final result = await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => ReziserFormScreen(item: reziser),
                                              ),
                                            );
                                            if (result == true) _fetchReziseri();
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.redAccent),
                                          tooltip: "Obriši",
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Potvrda brisanja"),
                                                content: Text("Da li ste sigurni da želite obrisati '${reziser.ime ?? ''} ${reziser.prezime ?? ''}'?"),
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
                                              final provider = Provider.of<ReziserProvider>(context, listen: false);
                                              await provider.delete(reziser.id);
                                              _fetchReziseri();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
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