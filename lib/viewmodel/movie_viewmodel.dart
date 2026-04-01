import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/data/repositories/movie_repository.dart';

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repository;

  MovieViewModel(this._repository);

  List<Results> _popularMovies = [];
  List<Results> _trendingMovies = [];
  List<Results> _nowPlayingMovies = [];

  List<Results> get popularMovies => _popularMovies;
  List<Results> get trendingMovies => _trendingMovies;
  List<Results> get nowPlayingMovies => _nowPlayingMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchPopularMovies(),
        _repository.fetchTrendingMovies(),
        _repository.fetchNowPlayingMovies(),
      ]);

      _popularMovies = results[0];
      _trendingMovies = results[1];
      _nowPlayingMovies = results[2];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
