import 'package:cinematic_desktop/providers/dobna_restrikcija_provider.dart';
import 'package:cinematic_desktop/providers/faq_kategorija_provider.dart';
import 'package:cinematic_desktop/providers/faq_provider.dart';
import 'package:cinematic_desktop/providers/film_provider.dart';
import 'package:cinematic_desktop/providers/glumac_provider.dart';
import 'package:cinematic_desktop/providers/hranaPice_provider.dart';
import 'package:cinematic_desktop/providers/izvjestaji_provider.dart';
import 'package:cinematic_desktop/providers/kategorijaHranePica_provider.dart';
import 'package:cinematic_desktop/providers/korisnik_provider.dart';
import 'package:cinematic_desktop/providers/nacin_prikazivanja_provider.dart';
import 'package:cinematic_desktop/providers/projekcija_provider.dart';
import 'package:cinematic_desktop/providers/recenzija_provider.dart';
import 'package:cinematic_desktop/providers/rezervacija_provider.dart';
import 'package:cinematic_desktop/providers/reziser_provider.dart';
import 'package:cinematic_desktop/providers/sala_provider.dart';
import 'package:cinematic_desktop/providers/sjediste_provider.dart';
import 'package:cinematic_desktop/providers/uloga_provider.dart';
import 'package:cinematic_desktop/providers/zanr_provider.dart';
import 'package:cinematic_desktop/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ZanrProvider>(
          create: (_) => ZanrProvider(),
        ),
        ChangeNotifierProvider<HranaPiceProvider>(
          create: (_) => HranaPiceProvider(),
        ),
        ChangeNotifierProvider<KategorijaHranePicaProvider>(
          create: (_) => KategorijaHranePicaProvider(),
        ),
        ChangeNotifierProvider<GlumacProvider>(
          create: (_) => GlumacProvider(),
        ),
        ChangeNotifierProvider<ReziserProvider>(
          create: (_) => ReziserProvider(),
        ),
        ChangeNotifierProvider<FaqKategorijaProvider>(
          create: (_) => FaqKategorijaProvider(),
        ),
        ChangeNotifierProvider<FaqProvider>(
          create: (_) => FaqProvider(),
        ),
        ChangeNotifierProvider<KorisnikProvider>(
          create: (_) => KorisnikProvider(),
        ),
        ChangeNotifierProvider<UlogaProvider>(
          create: (_) => UlogaProvider(),
        ),
        ChangeNotifierProvider<DobnaRestrikcijaProvider>(
          create: (_) => DobnaRestrikcijaProvider(),
        ),
        ChangeNotifierProvider<NacinPrikazivanjaProvider>(
          create: (_) => NacinPrikazivanjaProvider(),
        ),
        ChangeNotifierProvider<SalaProvider>(
          create: (_) => SalaProvider(),
        ),
        ChangeNotifierProvider<SjedisteProvider>(
          create: (_) => SjedisteProvider(),
        ),
        ChangeNotifierProvider<FilmProvider>(
          create: (_) => FilmProvider(),
        ),
        ChangeNotifierProvider<ProjekcijaProvider>(
          create: (_) => ProjekcijaProvider(),
        ),
        ChangeNotifierProvider<RecenzijaProvider>(
          create: (_) => RecenzijaProvider(),
        ),
        ChangeNotifierProvider<IzvjestajiProvider>(
          create: (_) => IzvjestajiProvider(),
        ),
        ChangeNotifierProvider<RezervacijaProvider>(
          create: (_) => RezervacijaProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.red,
        ),
      ),
      home: const LoginPage(),
    );
  }
}