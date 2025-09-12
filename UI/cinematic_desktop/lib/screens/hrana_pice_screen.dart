import 'package:cinematic_desktop/providers/hranaPice_provider.dart';
import 'package:cinematic_desktop/screens/hranaPice_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:cinematic_desktop/models/hrana_pice.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class HranaPiceScreen extends StatefulWidget {
  const HranaPiceScreen({super.key});

  @override
  State<HranaPiceScreen> createState() => _HranaPiceScreenState();
}

class _HranaPiceScreenState extends State<HranaPiceScreen> {
  List<HranaPice> _hranaPiceList = [];
  bool _isLoading = true;

  // Filter polja
  String? _nazivFilter;
  double? _cijenaMinFilter;
  double? _cijenaMaxFilter;
  final _nazivController = TextEditingController();
  final _cijenaMinController = TextEditingController();
  final _cijenaMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHranaPice();
  }

  @override
  void dispose() {
    _nazivController.dispose();
    _cijenaMinController.dispose();
    _cijenaMaxController.dispose();
    super.dispose();
  }

  Future<void> _fetchHranaPice() async {
    final provider = Provider.of<HranaPiceProvider>(context, listen: false);
    final filter = {
      'isKategorijeIncluded': true,
      if (_nazivFilter != null && _nazivFilter!.isNotEmpty)
        'nazivGTE': _nazivFilter,
      if (_cijenaMinFilter != null) 'cijenaMin': _cijenaMinFilter,
      if (_cijenaMaxFilter != null) 'cijenaMax': _cijenaMaxFilter,
    };
    final result = await provider.get(filter: filter);
    setState(() {
      _hranaPiceList = result.result;
      _isLoading = false;
    });
  }

  Widget _buildImage(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.fastfood, color: Colors.grey, size: 48),
      );
    }
    try {
      final bytes = base64Decode(base64);
      if (bytes.isEmpty) {
        throw Exception("Empty bytes");
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          bytes,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 90,
              height: 90,
              color: Colors.grey[200],
              child: Icon(Icons.fastfood, color: Colors.grey, size: 48),
            );
          },
        ),
      );
    } catch (e) {
      return Container(
        width: 90,
        height: 90,
        color: Colors.grey[200],
        child: Icon(Icons.fastfood, color: Colors.grey, size: 48),
      );
    }
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
                  Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  margin: const EdgeInsets.only(bottom: 24),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    child: Row(
      children: [
        // Svi inputi iste širine i iste visine
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nazivController,
                  decoration: InputDecoration(
                    labelText: "Naziv",
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _cijenaMinController,
                  decoration: InputDecoration(
                    labelText: "Cijena min",
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.arrow_downward),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _cijenaMaxController,
                  decoration: InputDecoration(
                    labelText: "Cijena max",
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.arrow_upward),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.filter_alt),
          label: Text("Pretraži"),
          onPressed: () {
            setState(() {
              _nazivFilter = _nazivController.text.isNotEmpty
                  ? _nazivController.text
                  : null;
              _cijenaMinFilter = double.tryParse(_cijenaMinController.text);
              _cijenaMaxFilter = double.tryParse(_cijenaMaxController.text);
              _isLoading = true;
            });
            _fetchHranaPice();
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.refresh),
          label: Text("Reset"),
          onPressed: () {
            _nazivController.clear();
            _cijenaMinController.clear();
            _cijenaMaxController.clear();
            setState(() {
              _nazivFilter = null;
              _cijenaMinFilter = null;
              _cijenaMaxFilter = null;
              _isLoading = true;
            });
            _fetchHranaPice();
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text("Dodaj"),
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HranaPiceFormScreen(),
              ),
            );
            if (result == true) _fetchHranaPice();
          },
        ),
      ],
    ),
  ),
),
                  Expanded(
                    child: _hranaPiceList.isEmpty
                        ? Center(child: Text("Nema hrane i pića."))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 1;
                              if (constraints.maxWidth > 1200) {
                                crossAxisCount = 4;
                              } else if (constraints.maxWidth > 900) {
                                crossAxisCount = 3;
                              } else if (constraints.maxWidth > 600) {
                                crossAxisCount = 2;
                              }
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: _hranaPiceList.length,
                                itemBuilder: (context, index) {
                                  final item = _hranaPiceList[index];
                                  return Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Center(child: _buildImage(item.slikaBase64)),
                                          const SizedBox(height: 12),
                                          Text(
                                            item.naziv ?? "",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey[900],
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.category, size: 18, color: Colors.orange),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  item.kategorija?.naziv ?? "",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.orange[800],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.description, size: 18, color: Colors.grey[700]),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  item.opis ?? "",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                                              const SizedBox(width: 4),
                                              Text(
                                                item.cijena?.toStringAsFixed(2) ?? "",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green[800],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.inventory_2, size: 18, color: Colors.blue[700]),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Skladište: ${item.kolicinaUskladistu ?? 0}",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.blue[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Tooltip(
                                                message: "Uredi",
                                                child: IconButton(
                                                  icon: Icon(Icons.edit, color: Colors.blue),
                                                  onPressed: () async {
                                                    final result = await Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => HranaPiceFormScreen(item: item),
                                                      ),
                                                    );
                                                    if (result == true) _fetchHranaPice();
                                                  },
                                                ),
                                              ),
                                              Tooltip(
                                                message: "Obriši",
                                                child: IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: Text("Potvrda brisanja"),
                                                        content: Text("Da li ste sigurni da želite obrisati '${item.naziv}'?"),
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
                                                      final provider = Provider.of<HranaPiceProvider>(context, listen: false);
                                                      await provider.delete(item.id);
                                                      _fetchHranaPice();
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