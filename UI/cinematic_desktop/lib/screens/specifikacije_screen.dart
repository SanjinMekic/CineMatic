import 'package:cinematic_desktop/models/dobna_restrikcija.dart';
import 'package:cinematic_desktop/models/nacin_prikazivanja.dart';
import 'package:cinematic_desktop/models/sala.dart';
import 'package:cinematic_desktop/models/sjediste.dart';
import 'package:cinematic_desktop/models/zanr.dart';
import 'package:cinematic_desktop/providers/dobna_restrikcija_provider.dart';
import 'package:cinematic_desktop/providers/nacin_prikazivanja_provider.dart';
import 'package:cinematic_desktop/providers/sala_provider.dart';
import 'package:cinematic_desktop/providers/sjediste_provider.dart';
import 'package:cinematic_desktop/providers/zanr_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinematic_desktop/providers/projekcija_provider.dart';

class SpecifikacijeScreen extends StatefulWidget {
  const SpecifikacijeScreen({super.key});

  @override
  State<SpecifikacijeScreen> createState() => _SpecifikacijeScreenState();
}

class _SpecifikacijeScreenState extends State<SpecifikacijeScreen> {
  late DobnaRestrikcijaProvider _dobnaRestrikcijaProvider;
  late NacinPrikazivanjaProvider _nacinPrikazivanjaProvider;
  late SalaProvider _salaProvider;
  late SjedisteProvider _sjedisteProvider;
  late ZanrProvider _zanrProvider;

  List<DobnaRestrikcija> _dobneRestrikcije = [];
  List<NacinPrikazivanja> _naciniPrikazivanja = [];
  List<Sala> _sale = [];
  List<Sjediste> _sjedista = [];
  List<Zanr> _zanrovi = [];

  bool _isLoading = true;

  List<bool> _expandedSections = [false, false, false, false, false];

  final _dobneSearchController = TextEditingController();
  final _naciniSearchController = TextEditingController();
  final _saleSearchController = TextEditingController();
  final _sjedistaSearchController = TextEditingController();
  final _zanroviSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dobnaRestrikcijaProvider = context.read<DobnaRestrikcijaProvider>();
    _nacinPrikazivanjaProvider = context.read<NacinPrikazivanjaProvider>();
    _salaProvider = context.read<SalaProvider>();
    _sjedisteProvider = context.read<SjedisteProvider>();
    _zanrProvider = context.read<ZanrProvider>();
    _loadData();
  }

  @override
  void dispose() {
    _dobneSearchController.dispose();
    _naciniSearchController.dispose();
    _saleSearchController.dispose();
    _sjedistaSearchController.dispose();
    _zanroviSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dobne = await _dobnaRestrikcijaProvider.get(
      filter:
          _dobneSearchController.text.isNotEmpty
              ? {'RestrikcijaOrOpis': _dobneSearchController.text}
              : null,
    );
    final nacini = await _nacinPrikazivanjaProvider.get(
      filter:
          _naciniSearchController.text.isNotEmpty
              ? {'NazivGTE': _naciniSearchController.text}
              : null,
    );
    final sale = await _salaProvider.get(
      filter:
          _saleSearchController.text.isNotEmpty
              ? {'NazivGTE': _saleSearchController.text}
              : null,
    );
    final sjedista = await _sjedisteProvider.get(
      filter:
          _sjedistaSearchController.text.isNotEmpty
              ? {'NazivGTE': _sjedistaSearchController.text}
              : null,
    );
    final zanrovi = await _zanrProvider.get(
      filter:
          _zanroviSearchController.text.isNotEmpty
              ? {'NazivGTE': _zanroviSearchController.text}
              : null,
    );
    setState(() {
      _dobneRestrikcije = dobne.result;
      _naciniPrikazivanja = nacini.result;
      _sale = sale.result;
      _sjedista = sjedista.result;
      _zanrovi = zanrovi.result;
      _isLoading = false;
    });
  }

  Future<bool> _showDeleteWarning(String naziv) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Upozorenje"),
        content: Text("Da li ste sigurni da želite obrisati \"$naziv\"?"),
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
    ) ?? false;
  }

  Future<void> _showDobnaRestrikcijaDialog({DobnaRestrikcija? item}) async {
    final restrikcijaController = TextEditingController(
      text: item?.restrikcija ?? "",
    );
    final opisController = TextEditingController(text: item?.opis ?? "");
    final isEdit = item != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEdit ? "Uredi dobnu restrikciju" : "Dodaj dobnu restrikciju",
        ),
        content: SizedBox(
          width: 400,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: restrikcijaController,
                decoration: InputDecoration(labelText: "Restrikcija"),
              ),
              TextField(
                controller: opisController,
                decoration: InputDecoration(labelText: "Opis"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "restrikcija": restrikcijaController.text,
                "opis": opisController.text,
              };
              if (isEdit) {
                await _dobnaRestrikcijaProvider.update(item.id, data);
              } else {
                await _dobnaRestrikcijaProvider.insert(data);
              }
              Navigator.of(context).pop(true);
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _showNacinPrikazivanjaDialog({NacinPrikazivanja? item}) async {
    final nazivController = TextEditingController(text: item?.naziv ?? "");
    final isEdit = item != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEdit ? "Uredi način prikazivanja" : "Dodaj način prikazivanja",
        ),
        content: SizedBox(
          width: 400,
          height: 50,
          child: TextField(
            controller: nazivController,
            decoration: InputDecoration(labelText: "Naziv"),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {"naziv": nazivController.text};
              if (isEdit) {
                await _nacinPrikazivanjaProvider.update(item.id, data);
              } else {
                await _nacinPrikazivanjaProvider.insert(data);
              }
              Navigator.of(context).pop(true);
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _showSalaDialog({Sala? item}) async {
    final nazivController = TextEditingController(text: item?.naziv ?? "");
    final isEdit = item != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Uredi salu" : "Dodaj salu"),
        content: SizedBox(
          width: 400,
          height: 50,
          child: TextField(
            controller: nazivController,
            decoration: InputDecoration(labelText: "Naziv"),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {"naziv": nazivController.text};
              if (isEdit) {
                await _salaProvider.update(item.id, data);
              } else {
                await _salaProvider.insert(data);
              }
              Navigator.of(context).pop(true);
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _showSjedisteDialog({Sjediste? item}) async {
    final nazivController = TextEditingController(text: item?.naziv ?? "");
    final isEdit = item != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Uredi sjedište" : "Dodaj sjedište"),
        content: SizedBox(
          width: 400,
          height: 50,
          child: TextField(
            controller: nazivController,
            decoration: InputDecoration(labelText: "Naziv"),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {"naziv": nazivController.text};
              if (isEdit) {
                await _sjedisteProvider.update(item.id, data);
              } else {
                await _sjedisteProvider.insert(data);
              }
              Navigator.of(context).pop(true);
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _showZanrDialog({Zanr? item}) async {
    final nazivController = TextEditingController(text: item?.naziv ?? "");
    final isEdit = item != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Uredi žanr" : "Dodaj žanr"),
        content: SizedBox(
          width: 400,
          height: 50,
          child: TextField(
            controller: nazivController,
            decoration: InputDecoration(labelText: "Naziv"),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {"naziv": nazivController.text};
              if (isEdit) {
                await _zanrProvider.update(item.id!, data);
              } else {
                await _zanrProvider.insert(data);
              }
              Navigator.of(context).pop(true);
            },
            child: Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true) _loadData();
  }

  void _onDobneSearch() => _loadData();
  void _onNaciniSearch() => _loadData();
  void _onSaleSearch() => _loadData();
  void _onSjedistaSearch() => _loadData();
  void _onZanroviSearch() => _loadData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildExpandableSection(
                    index: 0,
                    title: "Dobne restrikcije",
                    onAdd: () => _showDobnaRestrikcijaDialog(),
                    searchController: _dobneSearchController,
                    onSearch: _onDobneSearch,
                    searchHint: "Pretraži po restrikciji ili opisu",
                    children:
                        _dobneRestrikcije
                            .map(
                              (item) => ListTile(
                                title: Text(item.restrikcija ?? ""),
                                subtitle: Text(item.opis ?? ""),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed:
                                          () => _showDobnaRestrikcijaDialog(
                                            item: item,
                                          ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await _showDeleteWarning(item.restrikcija ?? "");
                                        if (confirm) {
                                          await _dobnaRestrikcijaProvider.delete(item.id);
                                          _loadData();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildExpandableSection(
                    index: 1,
                    title: "Načini prikazivanja",
                    onAdd: () => _showNacinPrikazivanjaDialog(),
                    searchController: _naciniSearchController,
                    onSearch: _onNaciniSearch,
                    searchHint: "Pretraži po nazivu",
                    children:
                        _naciniPrikazivanja
                            .map(
                              (item) => ListTile(
                                title: Text(item.naziv ?? ""),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed:
                                          () => _showNacinPrikazivanjaDialog(
                                            item: item,
                                          ),
                                    ),
                                    FutureBuilder<bool>(
                                      future: context.read<ProjekcijaProvider>().hasActiveForNacinPrikazivanja(item.id),
                                      builder: (context, snapshot) {
                                        final hasActive = snapshot.data ?? false;
                                        return IconButton(
                                          icon: Icon(Icons.delete, color: hasActive ? Colors.grey : Colors.red),
                                          tooltip: hasActive
                                              ? "Nije moguće obrisati jer postoje aktivne projekcije"
                                              : "Obriši",
                                          onPressed: hasActive
                                              ? null
                                              : () async {
                                                  final confirm = await _showDeleteWarning(item.naziv ?? "");
                                                  if (confirm) {
                                                    await _nacinPrikazivanjaProvider.delete(item.id);
                                                    _loadData();
                                                  }
                                                },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildExpandableSection(
                    index: 2,
                    title: "Sale",
                    onAdd: () => _showSalaDialog(),
                    searchController: _saleSearchController,
                    onSearch: _onSaleSearch,
                    searchHint: "Pretraži po nazivu",
                    children:
                        _sale
                            .map(
                              (item) => ListTile(
                                title: Text(item.naziv ?? ""),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed:
                                          () => _showSalaDialog(item: item),
                                    ),
                                    FutureBuilder<bool>(
                                      future: context.read<ProjekcijaProvider>().hasActiveForSala(item.id),
                                      builder: (context, snapshot) {
                                        final hasActive = snapshot.data ?? false;
                                        return IconButton(
                                          icon: Icon(Icons.delete, color: hasActive ? Colors.grey : Colors.red),
                                          tooltip: hasActive
                                              ? "Nije moguće obrisati jer postoje aktivne projekcije"
                                              : "Obriši",
                                          onPressed: hasActive
                                              ? null
                                              : () async {
                                                  final confirm = await _showDeleteWarning(item.naziv ?? "");
                                                  if (confirm) {
                                                    await _salaProvider.delete(item.id);
                                                    _loadData();
                                                  }
                                                },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildExpandableSection(
                    index: 3,
                    title: "Sjedišta",
                    onAdd: () => _showSjedisteDialog(),
                    searchController: _sjedistaSearchController,
                    onSearch: _onSjedistaSearch,
                    searchHint: "Pretraži po nazivu",
                    children:
                        _sjedista
                            .map(
                              (item) => ListTile(
                                title: Text(item.naziv ?? ""),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed:
                                          () => _showSjedisteDialog(item: item),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await _showDeleteWarning(item.naziv ?? "");
                                        if (confirm) {
                                          await _sjedisteProvider.delete(item.id);
                                          _loadData();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildExpandableSection(
                    index: 4,
                    title: "Žanrovi",
                    onAdd: () => _showZanrDialog(),
                    searchController: _zanroviSearchController,
                    onSearch: _onZanroviSearch,
                    searchHint: "Pretraži po nazivu",
                    children:
                        _zanrovi
                            .map(
                              (item) => ListTile(
                                title: Text(item.naziv ?? ""),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed:
                                          () => _showZanrDialog(item: item),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await _showDeleteWarning(item.naziv ?? "");
                                        if (confirm) {
                                          await _zanrProvider.delete(item.id!);
                                          _loadData();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
    );
  }

  Widget _buildExpandableSection({
    required int index,
    required String title,
    required VoidCallback onAdd,
    required TextEditingController searchController,
    required VoidCallback onSearch,
    required String searchHint,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _expandedSections[index],
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedSections[index] = expanded;
            });
          },
          tilePadding: EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(icon: Icon(Icons.add), onPressed: onAdd),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: searchHint,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                      onSubmitted: (_) => onSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: onSearch, child: Text("Pretraži")),
                ],
              ),
            ),
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Nema podataka."),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}