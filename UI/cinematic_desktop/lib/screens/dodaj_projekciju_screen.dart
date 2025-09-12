import 'package:cinematic_desktop/models/film.dart';
import 'package:cinematic_desktop/models/nacin_prikazivanja.dart';
import 'package:cinematic_desktop/models/projekcija.dart';
import 'package:cinematic_desktop/models/sala.dart';
import 'package:cinematic_desktop/providers/film_provider.dart';
import 'package:cinematic_desktop/providers/nacin_prikazivanja_provider.dart';
import 'package:cinematic_desktop/providers/projekcija_provider.dart';
import 'package:cinematic_desktop/providers/sala_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DodajProjekcijuScreen extends StatefulWidget {
  final Projekcija? projekcija;
  const DodajProjekcijuScreen({super.key, this.projekcija});

  @override
  State<DodajProjekcijuScreen> createState() => _DodajProjekcijuScreenState();
}

class _DodajProjekcijuScreenState extends State<DodajProjekcijuScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _filmId;
  int? _salaId;
  int? _nacinProjekcijeId;
  DateTime? _datum;
  TimeOfDay? _vrijeme;
  final _cijenaController = TextEditingController();
  String? _stanje;

  List<Film> _filmovi = [];
  List<Sala> _sale = [];
  List<NacinPrikazivanja> _nacini = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final filmovi = await context.read<FilmProvider>().get();
    final sale = await context.read<SalaProvider>().get();
    final nacini = await context.read<NacinPrikazivanjaProvider>().get();
    setState(() {
      _filmovi = filmovi.result;
      _sale = sale.result;
      _nacini = nacini.result;
      _isLoading = false;

      // Ako je edit, popuni polja
      if (widget.projekcija != null) {
        _filmId = widget.projekcija!.filmId;
        _salaId = widget.projekcija!.salaId;
        _nacinProjekcijeId = widget.projekcija!.nacinProjekcijeId;
        if (widget.projekcija!.datumIvrijeme != null) {
          _datum = widget.projekcija!.datumIvrijeme;
          _vrijeme = TimeOfDay.fromDateTime(widget.projekcija!.datumIvrijeme!);
        }
        _cijenaController.text = widget.projekcija!.cijena?.toString() ?? "";
        _stanje = widget.projekcija!.stanje;
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
       context: context,
  initialDate: _datum ?? now,
  firstDate: DateTime(2000, 1, 1),
  lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _datum = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _vrijeme ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _vrijeme = picked);
  }

    Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_filmId == null || _salaId == null || _nacinProjekcijeId == null || _datum == null || _vrijeme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Popunite sva polja.")),
      );
      return;
    }
    final datumIvrijeme = DateTime(
      _datum!.year,
      _datum!.month,
      _datum!.day,
      _vrijeme!.hour,
      _vrijeme!.minute,
    );

    // Onemogući dodavanje projekcije u prošlosti
    if (datumIvrijeme.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nije moguće dodati projekciju u prošlosti.")),
      );
      return;
    }

    final data = {
      "filmId": _filmId,
      "salaId": _salaId,
      "načinProjekcijeId": _nacinProjekcijeId,
      "datumIvrijeme": datumIvrijeme.toIso8601String(),
      "cijena": double.tryParse(_cijenaController.text),
      "stanje": _stanje ?? "active",
    };

    final provider = context.read<ProjekcijaProvider>();
    if (widget.projekcija == null) {
      await provider.insert(data);
    } else {
      await provider.update(widget.projekcija!.id!, data);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.projekcija == null ? "Dodaj projekciju" : "Uredi projekciju")),
      body: _isLoading
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
                        vertical: 32, horizontal: 40),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          DropdownButtonFormField<int>(
                            value: _filmId,
                            items: _filmovi
                                .map((f) => DropdownMenuItem(
                                      value: f.id,
                                      child: Text(f.naziv ?? ""),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _filmId = v),
                            decoration: InputDecoration(labelText: "Film"),
                            validator: (v) =>
                                v == null ? "Obavezno polje" : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _salaId,
                            items: _sale
                                .map((s) => DropdownMenuItem(
                                      value: s.id,
                                      child: Text(s.naziv ?? ""),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _salaId = v),
                            decoration: InputDecoration(labelText: "Sala"),
                            validator: (v) =>
                                v == null ? "Obavezno polje" : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _nacinProjekcijeId,
                            items: _nacini
                                .map((n) => DropdownMenuItem(
                                      value: n.id,
                                      child: Text(n.naziv ?? ""),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _nacinProjekcijeId = v),
                            decoration: InputDecoration(labelText: "Tehnologija prikaza"),
                            validator: (v) =>
                                v == null ? "Obavezno polje" : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _pickDate,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "Datum",
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _datum == null
                                          ? "Odaberite datum"
                                          : DateFormat('dd.MM.yyyy.').format(_datum!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: _pickTime,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "Vrijeme",
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _vrijeme == null
                                          ? "Odaberite vrijeme"
                                          : _vrijeme!.format(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cijenaController,
                            decoration: InputDecoration(labelText: "Cijena (KM)"),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || v.isEmpty ? "Obavezno polje" : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _stanje,
                            items: [
                              DropdownMenuItem(value: "active", child: Text("Aktivna")),
                              DropdownMenuItem(value: "hidden", child: Text("Skrivena")),
                            ],
                            onChanged: (v) => setState(() => _stanje = v),
                            decoration: InputDecoration(labelText: "Stanje"),
                            validator: (v) =>
                                v == null ? "Obavezno polje" : null,
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