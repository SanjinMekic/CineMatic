import 'dart:convert';
import 'package:cinematic_desktop/models/projekcija.dart';
import 'package:cinematic_desktop/models/zanr.dart';
import 'package:cinematic_desktop/providers/projekcija_provider.dart';
import 'package:cinematic_desktop/providers/zanr_provider.dart';
import 'package:cinematic_desktop/screens/rezervacije_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cinematic_desktop/screens/dodaj_projekciju_screen.dart';

class PocetnaScreen extends StatefulWidget {
  const PocetnaScreen({super.key});

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  bool prikaziAktivne = true;
  List<Projekcija> _projekcije = [];
  bool _isLoading = true;

  // Filter controllers
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
    if (prikaziAktivne && _odabraniDatum != null) {
      filter["Datum"] = DateFormat('yyyy-MM-dd').format(_odabraniDatum!);
    }

    final result = await provider.get(filter: filter);
    setState(() {
      _projekcije = result.result;
      _isLoading = false;
    });
  }

  Future<void> _sakrijProjekciju(Projekcija projekcija) async {
    final provider = context.read<ProjekcijaProvider>();
    await provider.update(projekcija.id!, {"stanje": "hidden"});
    _loadProjekcije();
  }

  Future<void> _aktivirajProjekciju(Projekcija projekcija) async {
    final provider = context.read<ProjekcijaProvider>();
    await provider.update(projekcija.id!, {"stanje": "active"});
    _loadProjekcije();
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
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
                ),
                onSubmitted: (_) => _loadProjekcije(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
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
            ),
            const SizedBox(width: 8),
            if (prikaziAktivne)
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _odabraniDatum ?? DateTime.now(),
                      firstDate: DateTime(2000),
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
                      suffixIcon:
                          _odabraniDatum != null
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
                        color:
                            _odabraniDatum != null
                                ? Colors.black
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            if (prikaziAktivne) const SizedBox(width: 8),
            ElevatedButton(onPressed: _loadProjekcije, child: Text("Pretraži")),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prikazane =
        _projekcije
            .where(
              (p) =>
                  prikaziAktivne
                      ? (p.stanje?.toLowerCase() == "aktivna" ||
                          p.stanje?.toLowerCase() == "active")
                      : (p.stanje?.toLowerCase() == "sakrivena" ||
                          p.stanje?.toLowerCase() == "hidden"),
            )
            .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Text(
                    "Dodaj projekciju",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DodajProjekcijuScreen()),
                  );
                  if (result == true) _loadProjekcije();
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!prikaziAktivne) {
                      setState(() {
                        prikaziAktivne = true;
                        _odabraniDatum = null;
                      });
                      _loadProjekcije();
                    }
                  },
                  child: Text(
                    "Aktivne projekcije",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          prikaziAktivne ? FontWeight.bold : FontWeight.normal,
                      color: prikaziAktivne ? Colors.blue : Colors.black,
                      decoration:
                          prikaziAktivne ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: () {
                    if (prikaziAktivne) {
                      setState(() {
                        prikaziAktivne = false;
                        _odabraniDatum = null;
                      });
                      _loadProjekcije();
                    }
                  },
                  child: Text(
                    "Sakrivene projekcije",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          !prikaziAktivne ? FontWeight.bold : FontWeight.normal,
                      color: !prikaziAktivne ? Colors.blue : Colors.black,
                      decoration:
                          !prikaziAktivne ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilterSection(),
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : prikazane.isEmpty
                      ? Text("Nema projekcija.")
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 1;
                          if (constraints.maxWidth > 1400) {
                            crossAxisCount = 3;
                          } else if (constraints.maxWidth > 1000) {
                            crossAxisCount = 2;
                          }
                          // Fiksna visina kartice
                          double cardHeight = 550;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio:
                                      constraints.maxWidth /
                                      (crossAxisCount * cardHeight),
                                ),
                            itemCount: prikazane.length,
                            itemBuilder: (context, index) {
                              final p = prikazane[index];
                              String? datumStr;
                              String? vrijemeStr;
                              if (p.datumIvrijeme != null) {
                                final dt = p.datumIvrijeme!;
                                datumStr = DateFormat('dd.MM.yyyy.').format(dt);
                                vrijemeStr = DateFormat('HH:mm').format(dt);
                              }
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
                              return SizedBox(
                                height: cardHeight,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        slikaWidget,
                                        const SizedBox(height: 12),
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
                                        const SizedBox(height: 8),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                prikaziAktivne
                                                    ? MainAxisAlignment.center
                                                    : MainAxisAlignment.start,
                                            children:
                                                [
                                                      if (prikaziAktivne)
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.orange,
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                          ),
                                                          onPressed: () async {
                                                            await _sakrijProjekciju(
                                                              p,
                                                            );
                                                          },
                                                          child: Text("Sakrij"),
                                                        ),
                                                      ElevatedButton.icon(
                                                        icon: Icon(
                                                          Icons.list_alt,
                                                        ),
                                                        label: Text(
                                                          "Pogledaj rezervacije",
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.indigo,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 8,
                                                              ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    _,
                                                                  ) => RezervacijeScreen(
                                                                    projekcijaId:
                                                                        p.id!,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      if (!prikaziAktivne)
                                                        (p.datumIvrijeme !=
                                                                    null &&
                                                                p.datumIvrijeme!
                                                                    .isBefore(
                                                                      DateTime.now(),
                                                                    ))
                                                            ? Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 8,
                                                                  ),
                                                              child: Text(
                                                                "Završena projekcija",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            )
                                                            : ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                              ),
                                                              onPressed: () async {
                                                                await _aktivirajProjekciju(
                                                                  p,
                                                                );
                                                              },
                                                              child: Text(
                                                                "Aktiviraj",
                                                              ),
                                                            ),
                                                      if (!prikaziAktivne &&
                                                          p.datumIvrijeme !=
                                                              null &&
                                                          p.datumIvrijeme!
                                                              .isAfter(
                                                                DateTime.now(),
                                                              ))
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.blue,
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 8,
                                                                ),
                                                          ),
                                                          onPressed: () async {
                                                            final result = await Navigator.of(
                                                              context,
                                                            ).push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      _,
                                                                    ) => DodajProjekcijuScreen(
                                                                      projekcija:
                                                                          p,
                                                                    ),
                                                              ),
                                                            );
                                                            if (result == true)
                                                              _loadProjekcije();
                                                          },
                                                          child: Text("Uredi"),
                                                        ),
                                                    ]
                                                    .map(
                                                      (w) => Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 8.0,
                                                            ),
                                                        child: w,
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (datumStr != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 18,
                                                color: Colors.grey[700],
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  datumStr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (vrijemeStr != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 18,
                                                color: Colors.grey[700],
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  vrijemeStr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (p.sala?.naziv != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.event_seat,
                                                size: 18,
                                                color: Colors.grey[700],
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  "Sala: ${p.sala!.naziv}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (p.nacinProjekcije != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.theaters,
                                                size: 18,
                                                color: Colors.grey[700],
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  "Tehnologija: ${p.nacinProjekcije!.naziv}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (p.cijena != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_money,
                                                size: 18,
                                                color: Colors.grey[700],
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  "Cijena: ${p.cijena} KM",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (p.film?.zanrs != null &&
                                            p.film!.zanrs!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.category,
                                                  size: 18,
                                                  color: Colors.grey[700],
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    "Žanrovi: ${p.film!.zanrs!.map((z) => z.naziv).join(', ')}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const Spacer(),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                p.stanje?.toLowerCase() ==
                                                            "active" ||
                                                        p.stanje?.toLowerCase() ==
                                                            "aktivna"
                                                    ? "AKTIVNA"
                                                    : "SAKRIVENA",
                                                style: TextStyle(
                                                  color:
                                                      prikaziAktivne
                                                          ? Colors.green
                                                          : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
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
