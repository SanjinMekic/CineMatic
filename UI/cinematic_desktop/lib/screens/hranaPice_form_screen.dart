import 'dart:convert';
import 'package:cinematic_desktop/models/hrana_pice.dart';
import 'package:cinematic_desktop/models/kategorija_hrane_pica.dart';
import 'package:cinematic_desktop/providers/hranaPice_provider.dart';
import 'package:cinematic_desktop/providers/kategorijaHranePica_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class HranaPiceFormScreen extends StatefulWidget {
  final HranaPice? item; // null za dodavanje, !=null za edit

  const HranaPiceFormScreen({super.key, this.item});

  @override
  State<HranaPiceFormScreen> createState() => _HranaPiceFormScreenState();
}

class _HranaPiceFormScreenState extends State<HranaPiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _kategorijaId;
  String? _naziv;
  double? _cijena;
  String? _opis;
  int? _kolicinaUskladistu;
  String? _slikaBase64;
  List<KategorijaHranePica> _kategorije = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchKategorije();
    if (widget.item != null) {
      _kategorijaId = widget.item!.kategorijaId;
      _naziv = widget.item!.naziv;
      _cijena = widget.item!.cijena;
      _opis = widget.item!.opis;
      _kolicinaUskladistu = widget.item!.kolicinaUskladistu;
      _slikaBase64 = widget.item!.slikaBase64;
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
    withData: true, // OVO DODAJ
  );
  if (result != null && result.files.single.bytes != null) {
    setState(() {
      _slikaBase64 = base64Encode(result.files.single.bytes!);
    });
    print('DEBUG: Odabrana slika, base64 length: ${_slikaBase64?.length}');
  } else {
    print('DEBUG: Nije odabrana slika');
  }
}

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final provider = Provider.of<HranaPiceProvider>(context, listen: false);
    final data = {
      if (widget.item != null) 'id': widget.item!.id,
      'kategorijaId': _kategorijaId,
      'naziv': _naziv,
      'cijena': _cijena,
      'opis': _opis,
      'količinaUskladištu': _kolicinaUskladistu,
      'slikaBase64': _slikaBase64 ?? widget.item?.slikaBase64,
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
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
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
                    TextFormField(
                      initialValue: _naziv,
                      decoration: InputDecoration(labelText: "Naziv"),
                      validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                      onSaved: (v) => _naziv = v,
                    ),
                    TextFormField(
                      initialValue: _cijena?.toString(),
                      decoration: InputDecoration(labelText: "Cijena"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                      onSaved: (v) => _cijena = double.tryParse(v ?? ''),
                    ),
                    TextFormField(
                      initialValue: _opis,
                      decoration: InputDecoration(labelText: "Opis"),
                      onSaved: (v) => _opis = v,
                    ),
                    TextFormField(
                      initialValue: _kolicinaUskladistu?.toString(),
                      decoration: InputDecoration(labelText: "Količina u skladištu"),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _kolicinaUskladistu = int.tryParse(v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.image),
                          label: Text("Odaberi sliku"),
                        ),
                        const SizedBox(width: 16),
                        if (_slikaBase64 != null)
                          Image.memory(
                            base64Decode(_slikaBase64!),
                            width: 60,
                            height: 60,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(widget.item == null ? "Dodaj" : "Sačuvaj"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}