import 'dart:convert';
import 'dart:typed_data';
import 'package:cinematic_desktop/models/dobna_restrikcija.dart';
import 'package:cinematic_desktop/models/film.dart';
import 'package:cinematic_desktop/models/glumac.dart';
import 'package:cinematic_desktop/models/reziser.dart';
import 'package:cinematic_desktop/models/zanr.dart';
import 'package:cinematic_desktop/providers/dobna_restrikcija_provider.dart';
import 'package:cinematic_desktop/providers/film_provider.dart';
import 'package:cinematic_desktop/providers/glumac_provider.dart';
import 'package:cinematic_desktop/providers/reziser_provider.dart';
import 'package:cinematic_desktop/providers/zanr_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DodajFilmScreen extends StatefulWidget {
  final Film? film;
  const DodajFilmScreen({super.key, this.film});

  @override
  State<DodajFilmScreen> createState() => _DodajFilmScreenState();
}

class _DodajFilmScreenState extends State<DodajFilmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nazivController = TextEditingController();
  final _trajanjeController = TextEditingController();
  final _opisController = TextEditingController();

  int? _dobnaRestrikcijaId;
  List<int> _odabraniGlumci = [];
  List<int> _odabraniReziseri = [];
  List<int> _odabraniZanrovi = [];
  String? _slikaBase64;
  Uint8List? _slikaBytes;

  List<DobnaRestrikcija> _dobneRestrikcije = [];
  List<Glumac> _glumci = [];
  List<Reziser> _reziseri = [];
  List<Zanr> _zanrovi = [];
  bool _isLoading = true;

  bool _slikaError = false;

  bool _glumciError = false;
  bool _reziseriError = false;
  bool _zanroviError = false;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final dobne = await context.read<DobnaRestrikcijaProvider>().get();
    final glumci = await context.read<GlumacProvider>().get();
    final reziseri = await context.read<ReziserProvider>().get();
    final zanrovi = await context.read<ZanrProvider>().get();
    setState(() {
      _dobneRestrikcije = dobne.result;
      _glumci = glumci.result;
      _reziseri = reziseri.result;
      _zanrovi = zanrovi.result;
      _isLoading = false;

      if (widget.film != null) {
        _nazivController.text = widget.film!.naziv ?? "";
        _trajanjeController.text = widget.film!.trajanje?.toString() ?? "";
        _opisController.text = widget.film!.opis ?? "";
        _dobnaRestrikcijaId = widget.film!.dobnaRestrikcijaId;
        _slikaBase64 = widget.film!.slikaBase64;
        if (_slikaBase64 != null) {
          _slikaBytes = base64Decode(_slikaBase64!);
        }
        _odabraniGlumci =
            widget.film!.glumacs?.map((g) => g.id).toList() ?? [];
        _odabraniReziseri =
            widget.film!.rezisers?.map((r) => r.id).toList() ?? [];
        _odabraniZanrovi = widget.film!.zanrs?.map((z) => z.id!).toList() ?? [];
      }
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _slikaBytes = result.files.single.bytes!;
        _slikaBase64 = base64Encode(_slikaBytes!);
        _slikaError = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _slikaError = _slikaBytes == null;
      _glumciError = _odabraniGlumci.isEmpty;
      _reziseriError = _odabraniReziseri.isEmpty;
      _zanroviError = _odabraniZanrovi.isEmpty;
    });

    if (!_formKey.currentState!.validate()) return;
    if (_slikaBytes == null) {
      setState(() {
        _slikaError = true;
      });
      return;
    }
    if (_dobnaRestrikcijaId == null) {
      return;
    }
    if (_odabraniGlumci.isEmpty ||
        _odabraniReziseri.isEmpty ||
        _odabraniZanrovi.isEmpty) {
      setState(() {
        _glumciError = _odabraniGlumci.isEmpty;
        _reziseriError = _odabraniReziseri.isEmpty;
        _zanroviError = _odabraniZanrovi.isEmpty;
      });
      return;
    }

    final data = {
      "naziv": _nazivController.text,
      "trajanje": int.tryParse(_trajanjeController.text),
      "opis": _opisController.text,
      "slikaBase64": _slikaBase64,
      "dobnaRestrikcijaId": _dobnaRestrikcijaId,
      "glumciID": _odabraniGlumci,
      "režiseriID": _odabraniReziseri,
      "žanroviID": _odabraniZanrovi,
    };

    final provider = context.read<FilmProvider>();
    if (widget.film == null) {
      await provider.insert(data);
    } else {
      await provider.update(widget.film!.id!, data);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.film == null ? "Dodaj film" : "Uredi film"),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 40,
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 48,
                                    backgroundImage:
                                        _slikaBytes != null
                                            ? MemoryImage(_slikaBytes!)
                                            : null,
                                    child:
                                        _slikaBytes == null
                                            ? Icon(Icons.add_a_photo, size: 48)
                                            : null,
                                  ),
                                  if (_slikaError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Slika je obavezna.",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nazivController,
                              decoration: InputDecoration(labelText: "Naziv"),
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? "Obavezno polje"
                                          : null,
                            ),
                            TextFormField(
                              controller: _trajanjeController,
                              decoration: InputDecoration(
                                labelText: "Trajanje (min)",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return "Obavezno polje";
                                final broj = int.tryParse(v);
                                if (broj == null || broj <= 0)
                                  return "Unesite pozitivan cijeli broj";
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _opisController,
                              decoration: InputDecoration(labelText: "Opis"),
                              maxLines: 3,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? "Obavezno polje"
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _dobnaRestrikcijaId,
                              items:
                                  _dobneRestrikcije
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d.id,
                                          child: Text(d.restrikcija ?? ""),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (v) =>
                                      setState(() => _dobnaRestrikcijaId = v),
                              decoration: InputDecoration(
                                labelText: "Dobna restrikcija",
                              ),
                              validator:
                                  (v) => v == null ? "Obavezno polje" : null,
                            ),
                            const SizedBox(height: 16),
                            _MultiSelectChipField<Glumac>(
                              label: "Glumci",
                              items: _glumci,
                              selectedIds: _odabraniGlumci,
                              itemLabel:
                                  (g) => "${g.ime ?? ""} ${g.prezime ?? ""}",
                              onSelectionChanged:
                                  (ids) => setState(() {
                                    _odabraniGlumci = ids;
                                    _glumciError = ids.isEmpty;
                                  }),
                            ),
                            if (_glumciError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 8.0,
                                ),
                                child: Text(
                                  "Morate odabrati barem 1 opciju.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            _MultiSelectChipField<Reziser>(
                              label: "Režiseri",
                              items: _reziseri,
                              selectedIds: _odabraniReziseri,
                              itemLabel:
                                  (r) => "${r.ime ?? ""} ${r.prezime ?? ""}",
                              onSelectionChanged:
                                  (ids) => setState(() {
                                    _odabraniReziseri = ids;
                                    _reziseriError = ids.isEmpty;
                                  }),
                            ),
                            if (_reziseriError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 8.0,
                                ),
                                child: Text(
                                  "Morate odabrati barem 1 opciju.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            _MultiSelectChipField<Zanr>(
                              label: "Žanrovi",
                              items: _zanrovi,
                              selectedIds: _odabraniZanrovi,
                              itemLabel: (z) => z.naziv ?? "",
                              onSelectionChanged:
                                  (ids) => setState(() {
                                    _odabraniZanrovi = ids;
                                    _zanroviError = ids.isEmpty;
                                  }),
                            ),
                            if (_zanroviError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 8.0,
                                ),
                                child: Text(
                                  "Morate odabrati barem 1 opciju.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("Otkaži"),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _save,
                                  child: Text("Sačuvaj"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}

class _MultiSelectChipField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final List<int> selectedIds;
  final String Function(T) itemLabel;
  final void Function(List<int>) onSelectionChanged;

  const _MultiSelectChipField({
    required this.label,
    required this.items,
    required this.selectedIds,
    required this.itemLabel,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        children:
            items.map((item) {
              final id = (item as dynamic).id as int;
              final selected = selectedIds.contains(id);
              return FilterChip(
                label: Text(itemLabel(item)),
                selected: selected,
                onSelected: (v) {
                  final newIds = List<int>.from(selectedIds);
                  if (v) {
                    newIds.add(id);
                  } else {
                    newIds.remove(id);
                  }
                  onSelectionChanged(newIds);
                },
              );
            }).toList(),
      ),
    );
  }
}
