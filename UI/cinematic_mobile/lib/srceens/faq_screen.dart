import 'dart:async';
import 'package:cinematic_mobile/models/faq.dart';
import 'package:cinematic_mobile/models/faq_kategorija.dart';
import 'package:cinematic_mobile/providers/faq_kategorija_provider.dart';
import 'package:cinematic_mobile/providers/faq_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<FaqKategorija> _kategorije = [];
  Map<int, List<Faq>> _faqPoKategoriji = {};
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchData(showLoading: true);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool showLoading = false}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    final kategorijaProvider = Provider.of<FaqKategorijaProvider>(
      context,
      listen: false,
    );
    final faqProvider = Provider.of<FaqProvider>(context, listen: false);

    final kategorijeResult = await kategorijaProvider.get();
    final faqResult = await faqProvider.get(
      filter: _searchFilter.isNotEmpty
          ? {'PitanjeOdgovorGTE': _searchFilter}
          : null,
    );

    setState(() {
      _kategorije = kategorijeResult.result;
      _faqPoKategoriji = {};
      for (var kat in _kategorije) {
        final faqs = faqResult.result.where((f) => f.kategorijaId == kat.id).toList();
        if (faqs.isNotEmpty) {
          _faqPoKategoriji[kat.id] = faqs;
        }
      }
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchFilter = _searchController.text;
      });
      _fetchData(showLoading: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQ")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Pretraži pitanja ili odgovore",
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _faqPoKategoriji.isEmpty
                        ? Center(
                            child: Text(
                              "Nema rezultata.",
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          )
                        : ListView(
                            children: _faqPoKategoriji.entries.map((entry) {
                              final kategorija = _kategorije.firstWhere((k) => k.id == entry.key);
                              final faqs = entry.value;
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  key: PageStorageKey<int>(kategorija.id),
                                  title: Text(
                                    kategorija.naziv ?? "",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  children: faqs
                                      .map(
                                        (faq) => ListTile(
                                          title: Text(
                                            faq.pitanje ?? "",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(faq.odgovor ?? ""),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}