import 'package:cinematic_desktop/providers/izvjestaji_provider.dart';
import 'package:cinematic_desktop/models/top_korisnik.dart';
import 'package:cinematic_desktop/models/broj_sjedista_po_filmu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

class IzvjestajiScreen extends StatefulWidget {
  const IzvjestajiScreen({super.key});

  @override
  State<IzvjestajiScreen> createState() => _IzvjestajiScreenState();
}

class _IzvjestajiScreenState extends State<IzvjestajiScreen> {
  int? brojKorisnika;
  int? brojAdmina;
  double? ukupnaZarada;
  double? ukupnaZaradaHranaPice;
  List<TopKorisnik> topKorisnici = [];
  List<BrojSjedistaPoFilmu> topFilmovi = [];
  bool _isLoading = true;

  static const double _cardWidth = 180;
  static const double _barChartWidth = _cardWidth * 2 + 12;

  @override
  void initState() {
    super.initState();
    _fetchPodaci();
  }

  Future<void> _fetchPodaci() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<IzvjestajiProvider>();
      final broj = await provider.getBrojKorisnika();
      final admina = await provider.getBrojAdmina();
      final zarada = await provider.getUkupnaZarada();
      final zaradaHranaPice = await provider.getUkupnaZaradaHranaPice();
      final top = await provider.getTop5Korisnika();
      final topFilmoviList = await provider.getTop5NajgledanijihFilmova();
      setState(() {
        brojKorisnika = broj;
        brojAdmina = admina;
        ukupnaZarada = zarada;
        ukupnaZaradaHranaPice = zaradaHranaPice;
        topKorisnici = top;
        topFilmovi = topFilmoviList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        brojKorisnika = null;
        brojAdmina = null;
        ukupnaZarada = null;
        ukupnaZaradaHranaPice = null;
        topKorisnici = [];
        topFilmovi = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška pri dohvatu izvještaja")));
    }
  }

  Future<void> _exportPdf() async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/DejaVuSans.ttf'),
    );
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(16),
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Izvještaj o korisnicima, adminima i zaradi",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: _cardWidth,
                      child: _pdfCard(
                        title: "Korisnici",
                        value: brojKorisnika?.toString() ?? "-",
                        color: PdfColors.blue,
                        font: font,
                        fontSize: 10,
                        valueFontSize: 16,
                        padding: 8,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Container(
                      width: _cardWidth,
                      child: _pdfCard(
                        title: "Administratori",
                        value: brojAdmina?.toString() ?? "-",
                        color: PdfColors.orange,
                        font: font,
                        fontSize: 10,
                        valueFontSize: 16,
                        padding: 8,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: _cardWidth,
                      child: _pdfCard(
                        title: "Ukupna zarada",
                        value:
                            ukupnaZarada != null
                                ? "${ukupnaZarada!.toStringAsFixed(2)} KM"
                                : "-",
                        color: PdfColors.green,
                        font: font,
                        fontSize: 10,
                        valueFontSize: 16,
                        padding: 8,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Container(
                      width: _cardWidth,
                      child: _pdfCard(
                        title: "Zarada hrana/pice",
                        value:
                            ukupnaZaradaHranaPice != null
                                ? "${ukupnaZaradaHranaPice!.toStringAsFixed(2)} KM"
                                : "-",
                        color: PdfColors.purple,
                        font: font,
                        fontSize: 10,
                        valueFontSize: 16,
                        padding: 8,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Top 5 korisnika po potrošnji",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: _barChartWidth,
                  child: pw.Column(
                    children: [
                      ...topKorisnici.map(
                        (k) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 60,
                                child: pw.Text(
                                  "${k.ime} ${k.prezime}",
                                  style: pw.TextStyle(font: font, fontSize: 7),
                                ),
                              ),
                              pw.SizedBox(width: 3),
                              pw.Container(
                                height: 8,
                                width:
                                    k.ukupnoPotrosenoNovca *
                                    (_barChartWidth - 90) /
                                    (topKorisnici.isNotEmpty
                                        ? topKorisnici
                                            .map((e) => e.ukupnoPotrosenoNovca)
                                            .reduce((a, b) => a > b ? a : b)
                                        : 1),
                                color: PdfColors.blue,
                              ),
                              pw.SizedBox(width: 3),
                              pw.Text(
                                "${k.ukupnoPotrosenoNovca.toStringAsFixed(2)} KM",
                                style: pw.TextStyle(font: font, fontSize: 7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Top 5 najgledanijih filmova (po broju rezervisanih sjedišta)",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: _barChartWidth,
                  child: pw.Column(
                    children: [
                      ...topFilmovi.map(
                        (f) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 60,
                                child: pw.Text(
                                  f.naziv,
                                  style: pw.TextStyle(font: font, fontSize: 7),
                                ),
                              ),
                              pw.SizedBox(width: 3),
                              pw.Container(
                                height: 8,
                                width:
                                    f.brojSjedista *
                                    (_barChartWidth - 90) /
                                    (topFilmovi.isNotEmpty
                                        ? topFilmovi
                                            .map((e) => e.brojSjedista)
                                            .reduce((a, b) => a > b ? a : b)
                                        : 1),
                                color: PdfColors.red,
                              ),
                              pw.SizedBox(width: 3),
                              pw.Text(
                                "${f.brojSjedista}",
                                style: pw.TextStyle(font: font, fontSize: 7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Izvjestaj.pdf',
    );
  }

  pw.Widget _pdfCard({
    required String title,
    required String value,
    required PdfColor color,
    required pw.Font font,
    double fontSize = 16,
    double valueFontSize = 32,
    double padding = 20,
  }) {
    PdfColor bgColor = PdfColors.white;
    if (color == PdfColors.blue) bgColor = PdfColors.blue100;
    if (color == PdfColors.orange) bgColor = PdfColors.orange100;
    if (color == PdfColors.green) bgColor = PdfColors.green100;
    if (color == PdfColors.purple) bgColor = PdfColors.purple100;

    return pw.Container(
      padding: pw.EdgeInsets.all(padding),
      margin: const pw.EdgeInsets.symmetric(horizontal: 2),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: color, width: 1.2),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: fontSize,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: valueFontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return SizedBox(
      width: _cardWidth,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color, width: 2),
        ),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topKorisniciBarChart() {
    if (topKorisnici.isEmpty) return SizedBox.shrink();
    final maxY =
        topKorisnici
            .map((e) => e.ukupnoPotrosenoNovca)
            .reduce((a, b) => a > b ? a : b) +
        10;
    return SizedBox(
      width: _barChartWidth,
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= topKorisnici.length) {
                    return SizedBox.shrink();
                  }
                  final korisnik = topKorisnici[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      "${korisnik.ime} ${korisnik.prezime}",
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < topKorisnici.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: topKorisnici[i].ukupnoPotrosenoNovca,
                    color: Colors.blue,
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _topFilmoviBarChart() {
    if (topFilmovi.isEmpty) return SizedBox.shrink();
    final maxY =
        topFilmovi.map((e) => e.brojSjedista).reduce((a, b) => a > b ? a : b) +
        5;
    return SizedBox(
      width: _barChartWidth,
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.toDouble(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget:
                    (value, meta) => Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= topFilmovi.length) {
                    return SizedBox.shrink();
                  }
                  final film = topFilmovi[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(film.naziv, style: TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < topFilmovi.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: topFilmovi[i].brojSjedista.toDouble(),
                    color: Colors.red,
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _card(
                                title: "Korisnici",
                                value: brojKorisnika?.toString() ?? "-",
                                color: Colors.blue,
                                bgColor: Colors.blue[50]!,
                              ),
                              SizedBox(width: 12),
                              _card(
                                title: "Administratori",
                                value: brojAdmina?.toString() ?? "-",
                                color: Colors.orange,
                                bgColor: Colors.orange[50]!,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _card(
                                title: "Ukupna zarada",
                                value:
                                    ukupnaZarada != null
                                        ? "${ukupnaZarada!.toStringAsFixed(2)} KM"
                                        : "-",
                                color: Colors.green,
                                bgColor: Colors.green[50]!,
                              ),
                              SizedBox(width: 12),
                              _card(
                                title: "Zarada hrana/pice",
                                value:
                                    ukupnaZaradaHranaPice != null
                                        ? "${ukupnaZaradaHranaPice!.toStringAsFixed(2)} KM"
                                        : "-",
                                color: Colors.purple,
                                bgColor: Colors.purple[50]!,
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Text(
                            "Top 5 korisnika po potrošnji",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _topKorisniciBarChart(),
                          SizedBox(height: 24),
                          Text(
                            "Top 5 najgledanijih filmova (po broju rezervisanih sjedišta)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _topFilmoviBarChart(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text("Export PDF"),
                      onPressed: _exportPdf,
                    ),
                  ),
                ],
              ),
    );
  }
}
