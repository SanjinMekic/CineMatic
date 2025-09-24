import 'dart:convert';
import 'dart:typed_data';
import 'package:cinematic_desktop/models/hrana_pice.dart';
import 'package:cinematic_desktop/models/kategorija_hrane_pica.dart';
import 'package:cinematic_desktop/providers/hranaPice_provider.dart';
import 'package:cinematic_desktop/providers/kategorijaHranePica_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class HranaPiceFormScreen extends StatefulWidget {
  final HranaPice? item;

  const HranaPiceFormScreen({super.key, this.item});

  @override
  State<HranaPiceFormScreen> createState() => _HranaPiceFormScreenState();
}

class _HranaPiceFormScreenState extends State<HranaPiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _kategorijaId;
  String? _naziv;
  String? _opis;
  String? _cijenaStr;
  String? _kolicinaStr;
  String? _slikaBase64;
  Uint8List? _slikaBytes;
  List<KategorijaHranePica> _kategorije = [];
  bool _isLoading = false;
  bool _slikaError = false;

  @override
  void initState() {
    super.initState();
    _fetchKategorije();
    if (widget.item != null) {
      _kategorijaId = widget.item!.kategorijaId;
      _naziv = widget.item!.naziv;
      _cijenaStr = widget.item!.cijena?.toString();
      _opis = widget.item!.opis;
      _kolicinaStr = widget.item!.kolicinaUskladistu?.toString();
      _slikaBase64 = widget.item!.slikaBase64;
      if (_slikaBase64 != null) {
        _slikaBytes = base64Decode(_slikaBase64!);
      }
    }
  }

  Future<void> _fetchKategorije() async {
    final provider = Provider.of<KategorijaHranePicaProvider>(context, listen: false);
    final result = await provider.get();
    setState(() {
      _kategorije = result.result;
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

  void _save() async {
    setState(() {
      _slikaError = _slikaBytes == null;
    });

    if (!_formKey.currentState!.validate() || _slikaBytes == null) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final provider = Provider.of<HranaPiceProvider>(context, listen: false);
    final data = {
      if (widget.item != null) 'id': widget.item!.id,
      'kategorijaId': _kategorijaId,
      'naziv': _naziv,
      'cijena': double.tryParse(_cijenaStr ?? ''),
      'opis': _opis,
      'količinaUskladištu': int.tryParse(_kolicinaStr ?? ''),
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
        title: Text(widget.item == null ? "Dodaj hranu/piće" : "Uredi hranu/piće"),
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
                          DropdownButtonFormField<int>(
                            value: _kategorijaId,
                            items: _kategorije
                                .map((k) => DropdownMenuItem(
                                      value: k.id,
                                      child: Text(k.naziv),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _kategorijaId = v),
                            decoration: InputDecoration(labelText: "Kategorija"),
                            validator: (v) => v == null ? "Obavezno polje" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _naziv,
                            decoration: InputDecoration(labelText: "Naziv"),
                            validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                            onSaved: (v) => _naziv = v,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _cijenaStr,
                            decoration: InputDecoration(labelText: "Cijena"),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Obavezno polje";
                              final cijena = double.tryParse(v.replaceAll(',', '.'));
                              if (cijena == null || cijena <= 0) return "Unesite pozitivan broj";
                              return null;
                            },
                            onSaved: (v) => _cijenaStr = v,
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
                            initialValue: _kolicinaStr,
                            decoration: InputDecoration(labelText: "Količina u skladištu"),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Obavezno polje";
                              final broj = int.tryParse(v);
                              if (broj == null || broj <= 0) return "Unesite pozitivan cijeli broj";
                              return null;
                            },
                            onSaved: (v) => _kolicinaStr = v,
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