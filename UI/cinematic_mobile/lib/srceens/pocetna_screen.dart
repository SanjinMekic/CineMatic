import 'dart:convert';
import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/models/zanr.dart';
import 'package:cinematic_mobile/providers/projekcija_provider.dart';
import 'package:cinematic_mobile/providers/zanr_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'projekcija_detalji_screen.dart';

class PocetnaScreen extends StatefulWidget {
  const PocetnaScreen({super.key});

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  List<Projekcija> _projekcije = [];
  bool _isLoading = true;

  final TextEditingController _nazivController = TextEditingController();
  DateTime? _odabraniDatum;
  int? _odabraniZanrId;
  List<Zanr> _zanrovi = [];

  @override
  void initState() {
    super.initState();
    _ucitajZanrove();
    _loadProjekcije();
  }

  Future<void> _ucitajZanrove() async {
    final zanrProvider = context.read<ZanrProvider>();
    final zanrResult = await zanrProvider.get();
    setState(() {
      _zanrovi = zanrResult.result;
    });
  }

  Future<void> _loadProjekcije() async {
    setState(() => _isLoading = true);
    final provider = context.read<ProjekcijaProvider>();
    final filter = <String, dynamic>{
      "isFilmoviIncluded": true,
      "isNačiniProjekcijeIncluded": true,
      "isSaleIncluded": true,
      "isŽanroviIncluded": true,
    };

    if (_nazivController.text.isNotEmpty) {
      filter["Naziv"] = _nazivController.text;
    }
    if (_odabraniZanrId != null) {
      filter["ZanrId"] = _odabraniZanrId;
    }
    if (_odabraniDatum != null) {
      filter["Datum"] = DateFormat('yyyy-MM-dd').format(_odabraniDatum!);
    }

    final result = await provider.get(filter: filter);
    setState(() {
      _projekcije = result.result;
      _isLoading = false;
    });
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        TextField(
  controller: _nazivController,
  decoration: InputDecoration(
    labelText: "Pretraži po nazivu filma",
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 12,
    ),
    suffixIcon: _nazivController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _nazivController.clear();
              });
              _loadProjekcije();
            },
          )
        : null,
  ),
  onSubmitted: (_) => _loadProjekcije(),
),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: _odabraniZanrId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: "Žanr",
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
          ),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text("Svi žanrovi"),
            ),
            ..._zanrovi.map(
              (zanr) => DropdownMenuItem<int>(
                value: zanr.id,
                child: Text(zanr.naziv ?? ""),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _odabraniZanrId = value;
            });
            _loadProjekcije();
          },
        ),
        const SizedBox(height: 10),
        InkWell(
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _odabraniDatum ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _odabraniDatum = picked;
      });
      _loadProjekcije();
    }
  },
  child: InputDecorator(
    decoration: InputDecoration(
      labelText: "Datum",
      border: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      suffixIcon: _odabraniDatum != null
          ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _odabraniDatum = null;
                });
                _loadProjekcije();
              },
            )
          : Icon(Icons.calendar_today),
    ),
    child: Text(
      _odabraniDatum != null
          ? DateFormat('dd.MM.yyyy.').format(_odabraniDatum!)
          : "Odaberi datum",
      style: TextStyle(
        color: _odabraniDatum != null
            ? Colors.black
            : Colors.grey[600],
      ),
    ),
  ),
),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loadProjekcije,
            child: Text("Pretraži"),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Projekcija> jedinstveniFilmovi = {};
    final aktivneProjekcije = _projekcije
    .where((p) {
      final stanjeOk = p.stanje?.toLowerCase() == "aktivna" || p.stanje?.toLowerCase() == "active";
      final datumProjekcije = p.datumIvrijeme;
      final datumOk = datumProjekcije != null && datumProjekcije.isAfter(DateTime.now());
      return stanjeOk && datumOk;
    })
    .toList();
    for (var p in aktivneProjekcije) {
      final film = p.film;
      if (film != null && film.id != null && !jedinstveniFilmovi.containsKey(film.id)) {
        jedinstveniFilmovi[film.id!] = p;
      }
    }
    final prikazane = jedinstveniFilmovi.values.toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : prikazane.isEmpty
                        ? Text("Nema aktivnih projekcija.")
                        : ListView.builder(
                            itemCount: prikazane.length,
                            itemBuilder: (context, index) {
                              final p = prikazane[index];
                              Widget? slikaWidget;
                              if (p.film?.slikaBase64 != null) {
                                try {
                                  slikaWidget = ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      base64Decode(p.film!.slikaBase64!),
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                } catch (_) {
                                  slikaWidget = Container(
                                    width: double.infinity,
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.broken_image, size: 48),
                                  );
                                }
                              } else {
                                slikaWidget = Container(
                                  width: double.infinity,
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.movie, size: 48),
                                );
                              }
                              final trajanje = p.film?.trajanje != null ? "${p.film!.trajanje} min" : null;
                              final zanrovi = (p.film?.zanrs != null && p.film!.zanrs!.isNotEmpty)
                                  ? p.film!.zanrs!.map((z) => z.naziv).join(', ')
                                  : null;
                              return GestureDetector(
                                onTap: () {
                                  print('Otvoren filmId: ${p.film?.id}');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProjekcijaDetaljiScreen(
                                        projekcija: p,
                                        filmId: p.film?.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      slikaWidget,
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              p.film?.naziv ?? "Nepoznat film",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (trajanje != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.schedule, size: 18, color: Colors.grey[700]),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      trajanje,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey[700],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (zanrovi != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.category, size: 18, color: Colors.blueGrey),
                                                    const SizedBox(width: 5),
                                                    Flexible(
                                                      child: Text(
                                                        zanrovi,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.blueGrey,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
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
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}