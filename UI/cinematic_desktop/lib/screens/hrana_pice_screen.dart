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
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.fastfood, color: Colors.grey, size: 60),
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
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              color: Colors.grey[200],
              child: Icon(Icons.fastfood, color: Colors.grey, size: 60),
            );
          },
        ),
      );
    } catch (e) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[200],
        child: Icon(Icons.fastfood, color: Colors.grey, size: 60),
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
                            icon: Icon(Icons.clear),
                            label: Text("Očisti filtere"),
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
                        : ListView.separated(
                            itemCount: _hranaPiceList.length,
                            separatorBuilder: (_, __) => SizedBox(height: 18),
                            itemBuilder: (context, index) {
                              final item = _hranaPiceList[index];
                              return Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: SizedBox(
                                    height: 140,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildImage(item.slikaBase64),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.naziv ?? "",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey[900],
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(Icons.category, size: 16, color: Colors.orange),
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
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(Icons.description, size: 16, color: Colors.grey[700]),
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
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
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
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(Icons.inventory_2, size: 16, color: Colors.blue[700]),
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
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
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