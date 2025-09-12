import 'package:cinematic_mobile/providers/auth_provider.dart';
import 'package:cinematic_mobile/providers/faq_kategorija_provider.dart';
import 'package:cinematic_mobile/providers/faq_provider.dart';
import 'package:cinematic_mobile/providers/hranaPice_provider.dart';
import 'package:cinematic_mobile/providers/korisnik_provider.dart';
import 'package:cinematic_mobile/providers/rezervacija_provider.dart';
import 'package:cinematic_mobile/providers/sjediste_provider.dart';
import 'package:cinematic_mobile/srceens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
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
        ChangeNotifierProvider<RezervacijaProvider>(
          create: (_) => RezervacijaProvider(),
        ),
        ChangeNotifierProvider<SjedisteProvider>(
          create: (_) => SjedisteProvider(),
        ),
        ChangeNotifierProvider<HranaPiceProvider>(
          create: (_) => HranaPiceProvider(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.red),
      ),
      home: LoginPage(),
    );
  }
}
