import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/manage_favorites.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class FakeFavoritesRepository implements MovieRepository {
  final List<Movie> _favs = [];

  @override
  Future<Either<Failure, List<Movie>>> getFavorites() async => Right(List.from(_favs));

  @override
  Future<Either<Failure, void>> addFavorite(Movie movie) async {
    if (!_favs.any((m) => m.id == movie.id)) {
      _favs.insert(0, movie);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int movieId) async {
    _favs.removeWhere((m) => m.id == movieId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async {
    return Right(_favs.any((m) => m.id == movieId));
  }

  // Stubs for remaining unused repository methods
  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, Movie>> getMovieDetails(int id) async => const Right(Movie(id: 1, title: '', overview: ''));
  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id) async => const Right([]);
  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id) async => const Right([]);
}

void main() {
  late FavoritesViewModel viewModel;
  late FakeFavoritesRepository repository;

  setUp(() {
    repository = FakeFavoritesRepository();
    viewModel = FavoritesViewModel(
      getFavoritesUseCase: GetFavorites(repository),
      addFavoriteUseCase: AddFavorite(repository),
      removeFavoriteUseCase: RemoveFavorite(repository),
      isFavoriteUseCase: IsFavorite(repository),
    );
  });

  const tMovie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'An insomniac office worker and a devil-may-care soap maker.',
    voteAverage: 8.4,
  );

  test('initial state should be ViewState.initial and favorites should be empty', () {
    expect(viewModel.state, ViewState.initial);
    expect(viewModel.favorites, isEmpty);
  });

  test('loadFavorites should set state to empty when no favorites exist', () async {
    await viewModel.loadFavorites();
    expect(viewModel.state, ViewState.empty);
    expect(viewModel.favorites, isEmpty);
  });

  test('addFavorite should insert movie and update state to success', () async {
    await viewModel.addFavorite(tMovie);

    expect(viewModel.favorites.length, 1);
    expect(viewModel.favorites.first, tMovie);
    expect(viewModel.isFavorite(tMovie.id), isTrue);
    expect(viewModel.state, ViewState.success);
  });

  test('removeFavorite should remove movie from favorites list', () async {
    await viewModel.addFavorite(tMovie);
    expect(viewModel.isFavorite(tMovie.id), isTrue);

    await viewModel.removeFavorite(tMovie.id);
    expect(viewModel.favorites, isEmpty);
    expect(viewModel.isFavorite(tMovie.id), isFalse);
    expect(viewModel.state, ViewState.empty);
  });
}
