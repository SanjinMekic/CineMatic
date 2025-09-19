import 'dart:convert';
import 'dart:typed_data';
import 'package:cinematic_desktop/models/reziser.dart';
import 'package:cinematic_desktop/providers/reziser_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReziserFormScreen extends StatefulWidget {
  final Reziser? item;
  const ReziserFormScreen({super.key, this.item});

  @override
  State<ReziserFormScreen> createState() => _ReziserFormScreenState();
}

class _ReziserFormScreenState extends State<ReziserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _ime;
  String? _prezime;
  DateTime? _datumRodjenja;
  String? _opis;
  String? _uspjesi;
  String? _rezisiraniFilmovi;
  String? _slikaBase64;
  Uint8List? _slikaBytes;
  bool _isLoading = false;

  String? _datumError;
  bool _slikaError = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _ime = widget.item!.ime;
      _prezime = widget.item!.prezime;
      _datumRodjenja = widget.item!.datumRodjenja;
      _opis = widget.item!.opis;
      _uspjesi = widget.item!.uspjesi;
      _rezisiraniFilmovi = widget.item!.rezisiraniFilmovi;
      _slikaBase64 = widget.item!.slikaBase64;
      if (_slikaBase64 != null) {
        _slikaBytes = base64Decode(_slikaBase64!);
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _slikaBytes = result.files.single.bytes!;
        _slikaBase64 = base64Encode(_slikaBytes!);
        _slikaError = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _datumRodjenja ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        _datumRodjenja = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
        _datumError = null;
      });
    }
  }

  void _save() async {
    setState(() {
      _datumError = _datumRodjenja == null ? "Obavezno polje" : null;
      _slikaError = _slikaBytes == null;
    });

    if (!_formKey.currentState!.validate() || _datumRodjenja == null || _slikaBytes == null) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final provider = Provider.of<ReziserProvider>(context, listen: false);
    final data = {
      if (widget.item != null) 'id': widget.item!.id,
      'ime': _ime,
      'prezime': _prezime,
      'datumRodjenja': _datumRodjenja?.toIso8601String(),
      'opis': _opis,
      'uspjesi': _uspjesi,
      'rezisiraniFilmovi': _rezisiraniFilmovi,
      'slikaBase64': _slikaBase64,
    };

    if (widget.item == null) {
      await provider.insert(data);
    } else {
      await provider.update(widget.item!.id, data);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? "Dodaj režisera" : "Uredi režisera"),
      ),
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
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
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
                                  backgroundImage: _slikaBytes != null
                                      ? MemoryImage(_slikaBytes!)
                                      : null,
                                  child: _slikaBytes == null
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
                            initialValue: _ime,
                            decoration: InputDecoration(labelText: "Ime"),
                            validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                            onSaved: (v) => _ime = v,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _prezime,
                            decoration: InputDecoration(labelText: "Prezime"),
                            validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                            onSaved: (v) => _prezime = v,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: "Datum rođenja",
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _datumRodjenja == null
                                        ? "Odaberite datum"
                                        : "${_datumRodjenja!.day.toString().padLeft(2, '0')}.${_datumRodjenja!.month.toString().padLeft(2, '0')}.${_datumRodjenja!.year}.",
                                  ),
                                ),
                              ),
                              if (_datumError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                                  child: Text(
                                    _datumError!,
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _opis,
                            decoration: InputDecoration(labelText: "Opis"),
                            maxLines: 3,
                            validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                            onSaved: (v) => _opis = v,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _uspjesi,
                            decoration: InputDecoration(labelText: "Uspjesi"),
                            maxLines: 2,
                            validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                            onSaved: (v) => _uspjesi = v,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _rezisiraniFilmovi,
                            decoration: InputDecoration(labelText: "Režisirani filmovi"),
                            maxLines: 2,
                            validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                            onSaved: (v) => _rezisiraniFilmovi = v,
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
                                child: Text(widget.item == null ? "Dodaj" : "Sačuvaj"),
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