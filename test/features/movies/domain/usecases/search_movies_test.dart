import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/search_movies.dart';
import '../../../../helpers/test_mock_repository.dart';

void main() {
  late TestMockMovieRepository repository;
  late SearchMovies usecase;

  final tMovie = const Movie(
    id: 1,
    title: 'Interstellar',
    overview: 'A team of explorers travel through a wormhole in space.',
    posterPath: '/interstellar.jpg',
    backdropPath: '/interstellar_back.jpg',
    voteAverage: 8.7,
    releaseDate: '2014-11-05',
    genreIds: [12, 18, 878],
  );

  setUp(() {
    repository = TestMockMovieRepository();
    usecase = SearchMovies(repository);
  });

  test('should call searchMulti when multi is true (default)', () async {
    repository.multiSearchResults = [tMovie];

    final result = await usecase('Interstellar');

    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Should succeed'),
      (movies) => expect(movies, [tMovie]),
    );
  });

  test('should call searchMovies when multi is false', () async {
    repository.searchResults = [tMovie];

    final result = await usecase('Interstellar', multi: false);

    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Should succeed'),
      (movies) => expect(movies, [tMovie]),
    );
  });

  test('should return Failure when repository encounters error', () async {
    repository.failure = const ServerFailure('Search service unavailable');

    final result = await usecase('Interstellar');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, const ServerFailure('Search service unavailable')),
      (movies) => fail('Should fail'),
    );
  });
}
