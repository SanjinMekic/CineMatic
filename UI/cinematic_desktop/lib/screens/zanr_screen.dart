import 'package:cinematic_desktop/layouts/master_screen.dart';
import 'package:cinematic_desktop/models/zanr.dart';
import 'package:cinematic_desktop/models/search_result.dart';
import 'package:cinematic_desktop/providers/zanr_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ZanrScreen extends StatefulWidget {
  const ZanrScreen({super.key});

  @override
  State<ZanrScreen> createState() => _ZanrScreenState();
}

class _ZanrScreenState extends State<ZanrScreen> {
  late ZanrProvider provider;

  void didChangeDependencies() {
    super.didChangeDependencies();

    provider = context.read<ZanrProvider>();
  }

  SearchResult<Zanr>? result = null;
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Lista proizvoda",
      Container(child: Column(children: [_buildSearch(), _buildResultView()])),
    );
  }

  TextEditingController _ftsEditingController = TextEditingController();
  TextEditingController _sifraController = TextEditingController();

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ftsEditingController,
              decoration: InputDecoration(labelText: "Naziv ili sifra"),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _sifraController,
              decoration: InputDecoration(labelText: "Sifra"),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              var filter = {'nazivGTE': _ftsEditingController.text};
              result = await provider.get(filter: filter);
              setState(() {});
            },
            child: Text("Pretraga"),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              //TODO
            },
            child: Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (result == null || result!.result.isEmpty) {
      return Expanded(child: Center(child: Text("Nema podataka")));
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: [
            DataColumn(label: Text("ID"), numeric: true),
            DataColumn(label: Text("Naziv")),
          ],
          rows:
              result!.result
                  .map<DataRow>(
                    (e) => DataRow(
                      cells: [
                        DataCell(Text(e.id?.toString() ?? "")),
                        DataCell(Text(e.naziv ?? "")),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
