import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/exceptions.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/core/network/network_info.dart';
import 'package:movie_app/features/movies/data/datasources/movie_local_data_source.dart';
import 'package:movie_app/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1}) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final remoteMovies = await remoteDataSource.getTrendingMovies(page: page);
        if (page == 1) {
          await localDataSource.cacheFeed(remoteMovies);
        }
        return Right(remoteMovies);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.statusCode));
      } on ConnectionException catch (e) {
        return _fallbackToCacheOrFailure(e.message);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return _fallbackToCacheOrFailure('No internet connection');
    }
  }

  Future<Either<Failure, List<Movie>>> _fallbackToCacheOrFailure(String message) async {
    final cached = await localDataSource.getCachedFeed();
    if (cached.isNotEmpty) {
      return Right(cached);
    }
    return Left(ConnectionFailure(message));
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final remoteMovies = await remoteDataSource.getPopularMovies(page: page);
      return Right(remoteMovies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final remoteMovies = await remoteDataSource.getTopRatedMovies(page: page);
      return Right(remoteMovies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1}) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final remoteMovies = await remoteDataSource.getUpcomingMovies(page: page);
      return Right(remoteMovies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1}) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final remoteMovies = await remoteDataSource.searchMovies(query, page: page);
      return Right(remoteMovies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final details = await remoteDataSource.getMovieDetails(id);
      return Right(details);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final credits = await remoteDataSource.getMovieCredits(id);
      return Right(credits);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final similar = await remoteDataSource.getSimilarMovies(id);
      return Right(similar);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(ConnectionFailure());
    }
    try {
      final trailers = await remoteDataSource.getMovieTrailers(id);
      return Right(trailers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getFavorites() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(Movie movie) async {
    try {
      final movieModel = MovieModel.fromEntity(movie);
      await localDataSource.addFavorite(movieModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int movieId) async {
    try {
      await localDataSource.removeFavorite(movieId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async {
    try {
      final isFav = await localDataSource.isFavorite(movieId);
      return Right(isFav);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
