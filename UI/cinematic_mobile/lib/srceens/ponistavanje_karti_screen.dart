import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/rezervacija_provider.dart';
import 'login_screen.dart';

class PonistavanjeKartiScreen extends StatefulWidget {
  const PonistavanjeKartiScreen({super.key});

  @override
  State<PonistavanjeKartiScreen> createState() =>
      _PonistavanjeKartiScreenState();
}

class _PonistavanjeKartiScreenState extends State<PonistavanjeKartiScreen> {
  String? scannedCode;
  bool _kameraAktivna = false;
  bool _loading = false;

  void _onDetect(BarcodeCapture capture) async {
    final code = capture.barcodes.first.rawValue;
    if (code != null && code != scannedCode) {
      setState(() {
        scannedCode = code;
        _kameraAktivna = false;
        _loading = true;
      });

      // Parsiraj ID rezervacije iz QR teksta
      final regex = RegExp(r'Rezervacija ID:\s*(\d+)');
      final match = regex.firstMatch(code);
      int? rezervacijaId;
      if (match != null && match.groupCount >= 1) {
        rezervacijaId = int.tryParse(match.group(1)!);
      }

      final rezervacijaProvider = Provider.of<RezervacijaProvider>(
        context,
        listen: false,
      );
      try {
        if (rezervacijaId == null) {
          throw Exception("Neispravan QR kod! ID nije pronađen.");
        }
        await rezervacijaProvider.ponistiKartu(rezervacijaId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karta je uspješno poništena!')),
        );
      } catch (e) {
        String errorMsg = e.toString();
        // Ukloni "Exception: " ako postoji
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.replaceFirst('Exception: ', '');
        }
        errorMsg = errorMsg.trim();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _otvoriKameru() {
    setState(() {
      _kameraAktivna = true;
      scannedCode = null;
    });
  }

  void _zatvoriKameru() {
    setState(() {
      _kameraAktivna = false;
    });
  }

  void _odjaviSe() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poništavanje karata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Odjavi se',
            onPressed: _odjaviSe,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_kameraAktivna)
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      MobileScanner(onDetect: _onDetect),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton(
                          heroTag: 'zatvoriKameru',
                          backgroundColor: Colors.red,
                          onPressed: _zatvoriKameru,
                          child: const Icon(Icons.close),
                          tooltip: 'Zatvori kameru',
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Expanded(
                  flex: 4,
                  child: Center(
                    child:
                        _loading
                            ? const CircularProgressIndicator()
                            : scannedCode == null
                            ? const Text(
                              'Kliknite na dugme ispod da otvorite kameru i skenirate QR kod karte.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            )
                            : Text(
                              'QR kod: $scannedCode',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Otvori kameru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _otvoriKameru,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
