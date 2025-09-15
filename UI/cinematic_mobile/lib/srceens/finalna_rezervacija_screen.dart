import 'package:cinematic_mobile/models/projekcija.dart';
import 'package:cinematic_mobile/models/hrana_pice.dart';
import 'package:cinematic_mobile/providers/rezervacija_provider.dart';
import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PregledRezervacijeScreen extends StatefulWidget {
  final Projekcija projekcija;
  final List<int> sjedistaIds;
  final List<HranaPice> odabranaHranaPica;
  final Map<int, int> kolicineHranePica;

  const PregledRezervacijeScreen({
    super.key,
    required this.projekcija,
    required this.sjedistaIds,
    required this.odabranaHranaPica,
    required this.kolicineHranePica,
  });

  @override
  State<PregledRezervacijeScreen> createState() => _PregledRezervacijeScreenState();
}

class _PregledRezervacijeScreenState extends State<PregledRezervacijeScreen> {
  String _nacinPlacanja = "gotovina";
  CardFieldInputDetails? _card;
  bool _loading = false;

  String _formatDatum(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('d.M.yyyy.').format(date);
  }

  String _formatVrijeme(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('HH:mm').format(date);
  }

  String _formatHranaPice() {
    if (widget.odabranaHranaPica.isEmpty) return '-';
    List<String> result = [];
    for (var h in widget.odabranaHranaPica) {
      final kolicina = widget.kolicineHranePica[h.id] ?? 1;
      result.add("${h.naziv ?? ''} x$kolicina");
    }
    return result.join(', ');
  }

  double _ukupnaCijena() {
    double cijenaKarte = (widget.projekcija.cijena ?? 0) * widget.sjedistaIds.length;
    double cijenaHrane = 0;
    for (var h in widget.odabranaHranaPica) {
      final kolicina = widget.kolicineHranePica[h.id] ?? 1;
      cijenaHrane += (h.cijena ?? 0) * kolicina;
    }
    return cijenaKarte + cijenaHrane;
  }

  Future<void> _rezervisi(BuildContext context, {String stripePaymentIntentId = ""}) async {
    setState(() => _loading = true);
    final korisnikId = AuthProvider.korisnikId;
    if (korisnikId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Niste prijavljeni.")),
      );
      setState(() => _loading = false);
      return;
    }
    final projekcijaId = widget.projekcija.id!;
    final hranaPiceIds = widget.odabranaHranaPica.map((h) => h.id).toList();
    final kolicine = widget.odabranaHranaPica.map((h) => widget.kolicineHranePica[h.id] ?? 1).toList();

    final body = {
      "korisnikId": korisnikId,
      "projekcijaId": projekcijaId,
      "sjedisteId": widget.sjedistaIds,
      "hranePicaId": hranaPiceIds,
      "kolicineHranePica": kolicine,
      "stripePaymentIntentId": stripePaymentIntentId,
    };

    final rezervacijaProvider = Provider.of<RezervacijaProvider>(context, listen: false);

    try {
      await rezervacijaProvider.insert(body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rezervacija uspješno kreirana!")),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri rezervaciji: $e")),
      );
    }
    setState(() => _loading = false);
  }

  Future<String?> _payWithStripe() async {
    // Ovdje bi trebao pozvati svoj backend da kreira PaymentIntent i vrati clientSecret
    // Ovdje je samo primjer sa dummy clientSecret-om
    const dummyClientSecret = "sk_test_dummy_client_secret";
    if (_card == null || !_card!.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite ispravne podatke o kartici.")),
      );
      return null;
    }
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: dummyClientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      // U pravoj aplikaciji, stripePaymentIntentId bi bio pravi id sa servera
      return dummyClientSecret;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stripe greška: $e")),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final salaNaziv = widget.projekcija.sala?.naziv ?? "-";
    final tehnologija = widget.projekcija.nacinProjekcije?.naziv ?? "-";
    final cijenaKarte = widget.projekcija.cijena ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pregled rezervacije"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.projekcija.film?.naziv ?? "Film",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text("Datum: ${_formatDatum(widget.projekcija.datumIvrijeme)}"),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text("Vrijeme: ${_formatVrijeme(widget.projekcija.datumIvrijeme)}"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_seat, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text("Sala: $salaNaziv"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.theaters, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text("Tehnologija: $tehnologija"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text("Cijena po karti: ${cijenaKarte.toStringAsFixed(2)} KM"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.event_seat, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Sjedista: ${widget.sjedistaIds.isNotEmpty ? widget.sjedistaIds.join(', ') : '-'}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fastfood, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Hrana i piće: ${_formatHranaPice()}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.payment, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text(
                    "Ukupna cijena: ${_ukupnaCijena().toStringAsFixed(2)} KM",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Odaberi način plaćanja:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "gotovina",
                    groupValue: _nacinPlacanja,
                    onChanged: (v) => setState(() => _nacinPlacanja = v!),
                  ),
                  const Text("Gotovina"),
                  Radio<String>(
                    value: "stripe",
                    groupValue: _nacinPlacanja,
                    onChanged: (v) => setState(() => _nacinPlacanja = v!),
                  ),
                  const Text("Stripe (kartica)"),
                ],
              ),
              if (_nacinPlacanja == "stripe")
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      height: 350,
                      child: CardFormField(
                        onCardChanged: (card) => setState(() => _card = card),
                        style: CardFormStyle(
                          borderColor: Colors.blueGrey,
                          borderRadius: 12,
                          fontSize: 20,
                          textColor: Colors.black,
                              placeholderColor: Colors.grey, // <-- placeholder je sivo
    backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check),
                  label: const Text("Rezerviši"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_nacinPlacanja == "stripe") {
                            if (_card == null || !_card!.complete) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Unesite ispravne podatke o kartici.")),
                              );
                              return;
                            }
                            final stripePaymentIntentId = await _payWithStripe();
                            if (stripePaymentIntentId == null) return;
                            await _rezervisi(context, stripePaymentIntentId: stripePaymentIntentId);
                          } else {
                            await _rezervisi(context);
                          }
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