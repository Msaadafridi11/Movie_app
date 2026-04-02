import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/data/repositories/movie_repository.dart';

class VideoViewModel extends ChangeNotifier {
  final MovieRepository _repository;

  VideoViewModel(this._repository);

  Results? _currentMovie;
  Results? get currentMovie => _currentMovie;

  String? _currentTrailerKey;
  String? get currentTrailerKey => _currentTrailerKey;

  List<Results> _relatedMovies = [];
  List<Results> get relatedMovies => _relatedMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> playMovie(Results movie) async {
    _currentMovie = movie;
    _relatedMovies = [];
    _currentTrailerKey = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (movie.id != null) {
        final similar = _repository.fetchSimilarMovies(movie.id!);
        final trailerKey = _repository.fetchMovieTrailer(movie.id!);
        
        _relatedMovies = await similar;
        _currentTrailerKey = await trailerKey;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
