import 'package:cinematic_desktop/models/faq.dart';
import 'package:cinematic_desktop/models/faq_kategorija.dart';
import 'package:cinematic_desktop/providers/faq_kategorija_provider.dart';
import 'package:cinematic_desktop/providers/faq_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
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

    // Prikazuj sve kategorije, a za svaku pronađi pitanja (može biti prazno)
    setState(() {
      _kategorije = kategorijeResult.result;
      _faqPoKategoriji = {};
      for (var kat in _kategorije) {
        _faqPoKategoriji[kat.id] =
            faqResult.result.where((f) => f.kategorijaId == kat.id).toList();
      }
      _isLoading = false;
    });
  }

  Future<void> _kreirajKategoriju() async {
    String? naziv;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Kreiraj kategoriju"),
        content: SizedBox(
          width: 400,
          height: 80,
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: "Naziv kategorije"),
            onChanged: (v) => naziv = v,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Kreiraj"),
          ),
        ],
      ),
    );
    if (result == true && naziv?.trim().isNotEmpty == true) {
      final provider = Provider.of<FaqKategorijaProvider>(
        context,
        listen: false,
      );
      await provider.insert({'naziv': naziv});
      _fetchData();
    }
  }

  Future<void> _urediKategoriju(FaqKategorija kategorija) async {
    String? naziv = kategorija.naziv;
    final nazivController = TextEditingController(text: naziv);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Uredi kategoriju"),
        content: SizedBox(
          width: 400,
          height: 80,
          child: TextField(
            autofocus: true,
            controller: nazivController,
            decoration: InputDecoration(labelText: "Naziv kategorije"),
            onChanged: (v) => naziv = v,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true && naziv?.trim().isNotEmpty == true) {
      final provider = Provider.of<FaqKategorijaProvider>(
        context,
        listen: false,
      );
      await provider.update(kategorija.id, {'naziv': naziv});
      _fetchData();
    }
  }

  Future<void> _obrisiKategoriju(FaqKategorija kategorija) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potvrda brisanja"),
        content: Text(
          "Obrisati kategoriju '${kategorija.naziv ?? ""}' i sva njena pitanja?",
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
      final provider = Provider.of<FaqKategorijaProvider>(
        context,
        listen: false,
      );
      await provider.delete(kategorija.id);
      _fetchData();
    }
  }

  Future<void> _urediPitanje(Faq faq) async {
    String? pitanje = faq.pitanje;
    String? odgovor = faq.odgovor;
    final pitanjeController = TextEditingController(text: pitanje);
    final odgovorController = TextEditingController(text: odgovor);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Uredi pitanje i odgovor"),
        content: SizedBox(
          width: 400,
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pitanjeController,
                decoration: InputDecoration(labelText: "Pitanje"),
                onChanged: (v) => pitanje = v,
              ),
              TextField(
                controller: odgovorController,
                decoration: InputDecoration(labelText: "Odgovor"),
                onChanged: (v) => odgovor = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true &&
        (pitanje?.trim().isNotEmpty == true) &&
        (odgovor?.trim().isNotEmpty == true)) {
      final provider = Provider.of<FaqProvider>(context, listen: false);
      await provider.update(faq.id, {
        'kategorijaId': faq.kategorijaId,
        'pitanje': pitanje,
        'odgovor': odgovor,
      });
      _fetchData();
    }
  }

  Future<void> _obrisiPitanje(Faq faq) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potvrda brisanja"),
        content: Text("Obrisati ovo pitanje i odgovor?"),
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
      final provider = Provider.of<FaqProvider>(context, listen: false);
      await provider.delete(faq.id);
      _fetchData();
    }
  }

  Future<void> _kreirajPitanje() async {
    int? kategorijaId = _kategorije.isNotEmpty ? _kategorije.first.id : null;
    String? pitanje;
    String? odgovor;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Kreiraj pitanje i odgovor"),
        content: SizedBox(
          width: 400,
          height: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: kategorijaId,
                items: _kategorije
                    .map(
                      (k) => DropdownMenuItem(
                        value: k.id,
                        child: Text(k.naziv ?? ""),
                      ),
                    )
                    .toList(),
                onChanged: (v) => kategorijaId = v,
                decoration: InputDecoration(labelText: "Kategorija"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Pitanje"),
                onChanged: (v) => pitanje = v,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Odgovor"),
                onChanged: (v) => odgovor = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Kreiraj"),
          ),
        ],
      ),
    );
    if (result == true &&
        kategorijaId != null &&
        (pitanje?.trim().isNotEmpty == true) &&
        (odgovor?.trim().isNotEmpty == true)) {
      final provider = Provider.of<FaqProvider>(context, listen: false);
      await provider.insert({
        'kategorijaId': kategorijaId,
        'pitanje': pitanje,
        'odgovor': odgovor,
      });
      _fetchData();
    }
  }

  void _onSearchPressed() {
    setState(() {
      _searchFilter = _searchController.text;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text("Kreiraj kategoriju"),
                          onPressed: _kreirajKategoriju,
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add_comment),
                          label: Text("Kreiraj pitanje i odgovor"),
                          onPressed:
                              _kategorije.isEmpty ? null : _kreirajPitanje,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: "Pretraži pitanja ili odgovore",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _onSearchPressed(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _onSearchPressed,
                          child: Text("Pretraži"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ExpansionPanelList.radio(
                      expandedHeaderPadding: EdgeInsets.zero,
                      children: _kategorije.map((kategorija) {
                        final faqs = _faqPoKategoriji[kategorija.id] ?? [];
                        return ExpansionPanelRadio(
                          value: kategorija.id,
                          headerBuilder: (context, isExpanded) => ListTile(
                            title: Text(
                              kategorija.naziv ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  tooltip: "Uredi kategoriju",
                                  onPressed: () => _urediKategoriju(kategorija),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Obriši kategoriju",
                                  onPressed: () => _obrisiKategoriju(kategorija),
                                ),
                              ],
                            ),
                          ),
                          body: faqs.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    "Nema pitanja u ovoj kategoriji.",
                                  ),
                                )
                              : Column(
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
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              faq.odgovor ?? "",
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                tooltip: "Uredi",
                                                onPressed: () =>
                                                    _urediPitanje(faq),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                tooltip: "Obriši",
                                                onPressed: () =>
                                                    _obrisiPitanje(faq),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}