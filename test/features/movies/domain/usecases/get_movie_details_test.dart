import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import '../../../../helpers/test_mock_repository.dart';

void main() {
  late TestMockMovieRepository repository;
  late GetMovieDetails usecase;

  final tMovie = const Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'An insomniac office worker and a devil-may-care soap maker form an underground fight club.',
    posterPath: '/fightclub.jpg',
    backdropPath: '/fightclub_back.jpg',
    voteAverage: 8.4,
    releaseDate: '1999-10-15',
    runtime: 139,
  );

  setUp(() {
    repository = TestMockMovieRepository();
    usecase = GetMovieDetails(repository);
  });

  test('should return movie details from repository with matching id and isTv flag', () async {
    repository.singleMovie = tMovie;

    final result = await usecase(550, isTv: false);

    expect(result, Right(tMovie));
    expect(repository.lastRequestedId, 550);
    expect(repository.lastRequestedIsTv, false);
  });

  test('should pass isTv true to repository when fetching TV details', () async {
    repository.singleMovie = tMovie;

    final result = await usecase(550, isTv: true);

    expect(result, Right(tMovie));
    expect(repository.lastRequestedIsTv, true);
  });

  test('should return failure when repository returns failure', () async {
    repository.failure = const ServerFailure('Movie not found');

    final result = await usecase(999999);

    expect(result, const Left(ServerFailure('Movie not found')));
  });
}
