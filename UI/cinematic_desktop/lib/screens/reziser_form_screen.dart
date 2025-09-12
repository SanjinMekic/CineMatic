import 'dart:convert';
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
  String? _slikaBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _ime = widget.item!.ime;
      _prezime = widget.item!.prezime;
      _datumRodjenja = widget.item!.datumRodjenja;
      _opis = widget.item!.opis;
      _slikaBase64 = widget.item!.slikaBase64;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _slikaBase64 = base64Encode(result.files.single.bytes!);
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final provider = Provider.of<ReziserProvider>(context, listen: false);
    final data = {
      if (widget.item != null) 'id': widget.item!.id,
      'ime': _ime,
      'prezime': _prezime,
      'datumRodjenja': _datumRodjenja?.toIso8601String(),
      'opis': _opis,
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
        title: Text(widget.item == null ? "Dodaj reditelja" : "Uredi reditelja"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _ime,
                      decoration: InputDecoration(labelText: "Ime"),
                      validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                      onSaved: (v) => _ime = v,
                    ),
                    TextFormField(
                      initialValue: _prezime,
                      decoration: InputDecoration(labelText: "Prezime"),
                      validator: (v) => v == null || v.isEmpty ? "Obavezno polje" : null,
                      onSaved: (v) => _prezime = v,
                    ),
                    const SizedBox(height: 16),
                    InputDatePickerFormField(
                      initialDate: _datumRodjenja ?? DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      fieldLabelText: "Datum rođenja",
                      onDateSaved: (date) => _datumRodjenja = date,
                      onDateSubmitted: (date) => _datumRodjenja = date,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _opis,
                      decoration: InputDecoration(labelText: "Opis"),
                      maxLines: 3,
                      onSaved: (v) => _opis = v,
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
                        if ((_slikaBase64 ?? widget.item?.slikaBase64) != null)
                          Image.memory(
                            base64Decode(_slikaBase64 ?? widget.item!.slikaBase64!),
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