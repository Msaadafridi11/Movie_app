import 'package:flutter/foundation.dart';
import 'package:movie_app/core/utils/debouncer.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/search_movies.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchMovies searchMovies;
  final Debouncer _debouncer = Debouncer(milliseconds: 450);

  SearchViewModel({required this.searchMovies});

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String _query = '';
  String get query => _query;

  List<Movie> _movies = [];
  List<Movie> get movies => _selectedGenreId == null
      ? _movies
      : _movies.where((m) => m.genreIds.contains(_selectedGenreId)).toList();

  int? _selectedGenreId;
  int? get selectedGenreId => _selectedGenreId;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get isEmpty => _state == ViewState.empty;
  bool get isSuccess => _state == ViewState.success;
  bool get hasError => _state == ViewState.error;

  void selectGenre(int? genreId) {
    if (_selectedGenreId == genreId) {
      _selectedGenreId = null;
    } else {
      _selectedGenreId = genreId;
    }
    notifyListeners();
  }

  void onQueryChanged(String newQuery) {
    final trimmed = newQuery.trim();
    if (trimmed == _query && _state != ViewState.initial) return;

    _query = trimmed;
    if (_query.isEmpty) {
      _movies = [];
      _state = ViewState.initial;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    _debouncer.run(() {
      _executeSearch(_query, 1);
    });
  }

  Future<void> _executeSearch(String query, int page) async {
    _currentPage = page;
    final result = await searchMovies(query, page: page);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = ViewState.error;
      },
      (newMovies) {
        if (page == 1) {
          _movies = newMovies;
        } else {
          _movies.addAll(newMovies);
        }

        _hasMore = newMovies.isNotEmpty;
        _state = _movies.isEmpty ? ViewState.empty : ViewState.success;
      },
    );

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _query.isEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await searchMovies(_query, page: nextPage);

    result.fold(
      (_) => _hasMore = false,
      (newMovies) {
        if (newMovies.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage = nextPage;
          _movies.addAll(newMovies);
        }
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _movies = [];
    _selectedGenreId = null;
    _state = ViewState.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
