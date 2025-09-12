import 'package:flutter/material.dart';
import 'package:cinematic_desktop/screens/pocetna_screen.dart';
import 'package:cinematic_desktop/screens/filmovi_screen.dart';
import 'package:cinematic_desktop/screens/glumci_screen.dart';
import 'package:cinematic_desktop/screens/reziseri_screen.dart';
import 'package:cinematic_desktop/screens/specifikacije_screen.dart';
import 'package:cinematic_desktop/screens/hrana_pice_screen.dart';
import 'package:cinematic_desktop/screens/korisnici_admini_screen.dart';
import 'package:cinematic_desktop/screens/faq_screen.dart';
import 'package:cinematic_desktop/screens/izvjestaji_screen.dart';
import 'package:cinematic_desktop/screens/profil_screen.dart';
import 'package:cinematic_desktop/screens/login_screen.dart';

class MasterScreen extends StatefulWidget {
  final String title;
  final Widget child;

  const MasterScreen(this.title, this.child, {super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  double _rotation = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: 80,
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CineMatic",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _rotation = 0.5; // 1 turn = 360°
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _rotation = 0;
                      });
                    },
                    child: AnimatedRotation(
                      turns: _rotation,
                      duration: Duration(milliseconds: 200),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Početna"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MasterScreen("Početna", PocetnaScreen()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.movie),
              title: Text("Filmovi"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MasterScreen("Filmovi", FilmoviScreen()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Glumci"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MasterScreen("Glumci", GlumciScreen()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.video_camera_back),
              title: Text("Režiseri"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MasterScreen("Režiseri", ReziseriScreen()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Specifikacije"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MasterScreen(
                          "Specifikacije",
                          SpecifikacijeScreen(),
                        ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text("Hrana i piće"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MasterScreen("Hrana i piće", HranaPiceScreen()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text("Korisnici i admini"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MasterScreen(
                          "Korisnici i admini",
                          KorisniciAdminiScreen(),
                        ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("FAQ"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MasterScreen("FAQ", FaqScreen()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text("Izvještaji"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MasterScreen("Izvještaji", IzvjestajiScreen()),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Profil"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) => MasterScreen("Profil", ProfilScreen()),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Odjava"),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
