class TopKorisnik {
  final int korisnikId;
  final String ime;
  final String prezime;
  final double ukupnoPotrosenoNovca;

  TopKorisnik({
    required this.korisnikId,
    required this.ime,
    required this.prezime,
    required this.ukupnoPotrosenoNovca,
  });

  factory TopKorisnik.fromJson(Map<String, dynamic> json) => TopKorisnik(
        korisnikId: json['korisnikd'] ?? json['korisnikId'] ?? 0,
        ime: json['ime'] ?? '',
        prezime: json['prezime'] ?? '',
        ukupnoPotrosenoNovca: (json['ukupnoPotrosenoNovca'] ?? 0).toDouble(),
      );
}