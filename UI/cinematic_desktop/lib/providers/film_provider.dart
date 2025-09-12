import 'package:cinematic_desktop/models/film.dart';
import 'package:cinematic_desktop/providers/base_provider.dart';

class FilmProvider extends BaseProvider<Film> {
  FilmProvider() : super("Filmovi");

  @override
  Film fromJson(data) => Film.fromJson(data);
}