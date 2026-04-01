import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/data/repositories/movie_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository _repository;

  SearchViewModel(this._repository);

  List<Results> _searchedMovies = [];
  List<Results> get searchedMovies => _searchedMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _searchedMovies = [];
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchedMovies = await _repository.searchMovies(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
