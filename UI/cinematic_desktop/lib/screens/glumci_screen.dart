import 'dart:convert';
import 'package:cinematic_desktop/models/glumac.dart';
import 'package:cinematic_desktop/providers/glumac_provider.dart';
import 'package:cinematic_desktop/screens/glumac_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GlumciScreen extends StatefulWidget {
  const GlumciScreen({super.key});

  @override
  State<GlumciScreen> createState() => _GlumciScreenState();
}

class _GlumciScreenState extends State<GlumciScreen> {
  List<Glumac> _glumci = [];
  bool _isLoading = true;

  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  String? _imeFilter;
  String? _prezimeFilter;

  @override
  void initState() {
    super.initState();
    _fetchGlumci();
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    super.dispose();
  }

  Future<void> _fetchGlumci() async {
    final provider = Provider.of<GlumacProvider>(context, listen: false);
    final filter = {
      if (_imeFilter != null && _imeFilter!.isNotEmpty) 'imeGTE': _imeFilter,
      if (_prezimeFilter != null && _prezimeFilter!.isNotEmpty)
        'prezimeGTE': _prezimeFilter,
    };
    final result = await provider.get(filter: filter);
    setState(() {
      _glumci = result.result;
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

  void _showGlumacDetalji(Glumac glumac) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      glumac.slikaBase64 != null &&
                              glumac.slikaBase64!.isNotEmpty
                          ? MemoryImage(base64Decode(glumac.slikaBase64!))
                          : null,
                  child:
                      (glumac.slikaBase64 == null ||
                              glumac.slikaBase64!.isEmpty)
                          ? Icon(Icons.person, size: 32)
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "${glumac.ime ?? ''} ${glumac.prezime ?? ''}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 600,
              height: 200,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (glumac.datumRodjenja != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(Icons.cake, color: Colors.purple, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Datum rođenja: ${DateFormat('dd.MM.yyyy.').format(glumac.datumRodjenja!)}",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    if (glumac.opis != null && glumac.opis!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                glumac.opis!,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (glumac.uspjesi != null && glumac.uspjesi!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 20,
                            ),
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
                                    glumac.uspjesi!,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (glumac.ulogeUfilmovima != null &&
                        glumac.ulogeUfilmovima!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.movie,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Uloge u filmovima:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  Text(
                                    glumac.ulogeUfilmovima!,
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
      body:
          _isLoading
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
                              _imeFilter =
                                  _imeController.text.isNotEmpty
                                      ? _imeController.text
                                      : null;
                              _prezimeFilter =
                                  _prezimeController.text.isNotEmpty
                                      ? _prezimeController.text
                                      : null;
                              _isLoading = true;
                            });
                            _fetchGlumci();
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          child: Text("Očisti filtere"),
                          onPressed: () {
                            _imeController.clear();
                            _prezimeController.clear();
                            setState(() {
                              _imeFilter = null;
                              _prezimeFilter = null;
                              _isLoading = true;
                            });
                            _fetchGlumci();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Dugme Dodaj
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
                                builder: (context) => GlumacFormScreen(),
                              ),
                            );
                            if (result == true) _fetchGlumci();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          _glumci.isEmpty
                              ? Center(
                                child: Text(
                                  "Nema glumaca.",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              )
                              : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 24,
                                      crossAxisSpacing: 24,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: _glumci.length,
                                itemBuilder: (context, index) {
                                  final glumac = _glumci[index];
                                  return GestureDetector(
                                    onTap: () => _showGlumacDetalji(glumac),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: _buildImage(
                                                glumac.slikaBase64,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.6,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(12),
                                                      bottomRight:
                                                          Radius.circular(12),
                                                    ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 8,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "${glumac.ime ?? ''} ${glumac.prezime ?? ''}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                    ),
                                                    tooltip: "Uredi",
                                                    onPressed: () async {
                                                      FocusScope.of(
                                                        context,
                                                      ).requestFocus(
                                                        FocusNode(),
                                                      );
                                                      final result =
                                                          await Navigator.of(
                                                            context,
                                                          ).push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => GlumacFormScreen(
                                                                    item:
                                                                        glumac,
                                                                  ),
                                                            ),
                                                          );
                                                      if (result == true)
                                                        _fetchGlumci();
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                    ),
                                                    tooltip: "Obriši",
                                                    onPressed: () async {
                                                      final confirm = await showDialog<
                                                        bool
                                                      >(
                                                        context: context,
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AlertDialog(
                                                              title: Text(
                                                                "Potvrda brisanja",
                                                              ),
                                                              content: Text(
                                                                "Da li ste sigurni da želite obrisati '${glumac.ime ?? ''} ${glumac.prezime ?? ''}'?",
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.of(
                                                                        context,
                                                                      ).pop(
                                                                        false,
                                                                      ),
                                                                  child: Text(
                                                                    "Otkaži",
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.of(
                                                                        context,
                                                                      ).pop(
                                                                        true,
                                                                      ),
                                                                  child: Text(
                                                                    "Obriši",
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                      );
                                                      if (confirm == true) {
                                                        final provider =
                                                            Provider.of<
                                                              GlumacProvider
                                                            >(
                                                              context,
                                                              listen: false,
                                                            );
                                                        await provider.delete(
                                                          glumac.id,
                                                        );
                                                        _fetchGlumci();
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
