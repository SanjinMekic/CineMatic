import 'package:cinematic_mobile/models/film.dart';
import 'package:cinematic_mobile/providers/base_provider.dart';

class FilmProvider extends BaseProvider<Film> {
  FilmProvider() : super("Filmovi");

  @override
  Film fromJson(data) => Film.fromJson(data);
}