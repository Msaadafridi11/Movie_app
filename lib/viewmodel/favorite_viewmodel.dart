import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie_model.dart';

class FavoriteViewModel extends ChangeNotifier {
  final List<Results> _favoriteMovies = [];

  List<Results> get favoriteMovies => _favoriteMovies;

  bool isFavorite(Results movie) {
    return _favoriteMovies.any((m) => m.id == movie.id);
  }

  void toggleFavorite(Results movie) {
    if (isFavorite(movie)) {
      _favoriteMovies.removeWhere((m) => m.id == movie.id);
    } else {
      _favoriteMovies.add(movie);
    }
    notifyListeners();
  }
}
