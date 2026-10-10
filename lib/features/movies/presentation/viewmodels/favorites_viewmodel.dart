import 'package:flutter/foundation.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/manage_favorites.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class FavoritesViewModel extends ChangeNotifier {
  final GetFavorites getFavoritesUseCase;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;
  final IsFavorite isFavoriteUseCase;

  FavoritesViewModel({
    required this.getFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.isFavoriteUseCase,
  });

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  List<Movie> _favorites = [];
  List<Movie> get favorites => _favorites;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get isEmpty => _state == ViewState.empty;
  bool get isSuccess => _state == ViewState.success;

  bool isFavorite(int movieId) {
    return _favorites.any((m) => m.id == movieId);
  }

  Future<void> loadFavorites() async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await getFavoritesUseCase();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = ViewState.error;
      },
      (movies) {
        _favorites = movies;
        _state = _favorites.isEmpty ? ViewState.empty : ViewState.success;
      },
    );

    notifyListeners();
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await removeFavorite(movie.id);
    } else {
      await addFavorite(movie);
    }
  }

  Future<void> addFavorite(Movie movie) async {
    if (!isFavorite(movie.id)) {
      _favorites.insert(0, movie);
      _state = ViewState.success;
      notifyListeners();
      await addFavoriteUseCase(movie);
    }
  }

  Future<void> removeFavorite(int movieId) async {
    _favorites.removeWhere((m) => m.id == movieId);
    if (_favorites.isEmpty) {
      _state = ViewState.empty;
    }
    notifyListeners();
    await removeFavoriteUseCase(movieId);
  }
}
