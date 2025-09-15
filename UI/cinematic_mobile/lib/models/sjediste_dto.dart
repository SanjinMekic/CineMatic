class SjedisteDTO {
  final int id;
  final String? naziv;
  final bool rezervisano;

  SjedisteDTO({
    required this.id,
    this.naziv,
    required this.rezervisano,
  });

  factory SjedisteDTO.fromJson(Map<String, dynamic> json) => SjedisteDTO(
        id: json['id'],
        naziv: json['naziv'],
        rezervisano: json['rezervisano'] ?? false,
      );
}