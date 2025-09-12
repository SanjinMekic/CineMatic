class BrojSjedistaPoFilmu {
  final int filmId;
  final String naziv;
  final int brojSjedista;

  BrojSjedistaPoFilmu({
    required this.filmId,
    required this.naziv,
    required this.brojSjedista,
  });

  factory BrojSjedistaPoFilmu.fromJson(Map<String, dynamic> json) =>
      BrojSjedistaPoFilmu(
        filmId: json['filmId'] ?? 0,
        naziv: json['naziv'] ?? '',
        brojSjedista: json['brojSjedista'] ?? 0,
      );
}