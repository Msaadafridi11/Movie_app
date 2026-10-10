import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/core/network/network_info.dart';
import 'package:movie_app/features/movies/data/datasources/movie_local_data_source.dart';
import 'package:movie_app/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:movie_app/features/movies/data/repositories_impl/movie_repository_impl.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/get_discover_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_credits.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_images.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_recommendations.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_trailers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_watch_providers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_omdb_ratings.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_tv_shows.dart';
import 'package:movie_app/features/movies/domain/usecases/get_similar_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_trending_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_upcoming_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/manage_favorites.dart';
import 'package:movie_app/features/movies/domain/usecases/search_movies.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/home_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/search_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/theme_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> initInjection() async {
  // 1. External & Singletons
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // 2. Core
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // 3. Data Sources
  getIt.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<MovieLocalDataSource>(
    () => MovieLocalDataSourceImpl(getIt<SharedPreferences>()),
  );

  // 4. Repositories
  getIt.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: getIt<MovieRemoteDataSource>(),
      localDataSource: getIt<MovieLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // 5. Use Cases
  getIt.registerLazySingleton(() => GetTrendingMovies(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetPopularMovies(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetTopRatedMovies(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetUpcomingMovies(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetPopularTvShows(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetDiscoverMovies(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => SearchMovies(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetMovieDetails(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetMovieCredits(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetSimilarMovies(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetMovieRecommendations(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetMovieTrailers(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetMovieWatchProviders(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetMovieImages(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetOmdbRatings(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => GetFavorites(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => AddFavorite(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => RemoveFavorite(getIt<MovieRepository>()));
  getIt.registerLazySingleton(() => IsFavorite(getIt<MovieRepository>()));

  // 6. ViewModels (ChangeNotifier)
  getIt.registerFactory(
    () => HomeViewModel(
      getTrendingMovies: getIt<GetTrendingMovies>(),
      getPopularMovies: getIt<GetPopularMovies>(),
      getTopRatedMovies: getIt<GetTopRatedMovies>(),
      getUpcomingMovies: getIt<GetUpcomingMovies>(),
      getPopularTvShows: getIt<GetPopularTvShows>(),
      getDiscoverMovies: getIt<GetDiscoverMovies>(),
      getMovieTrailers: getIt<GetMovieTrailers>(),
    ),
  );

  getIt.registerFactory(
    () => MovieDetailViewModel(
      getMovieDetails: getIt<GetMovieDetails>(),
      getMovieCredits: getIt<GetMovieCredits>(),
      getSimilarMovies: getIt<GetSimilarMovies>(),
      getMovieRecommendations: getIt<GetMovieRecommendations>(),
      getMovieTrailers: getIt<GetMovieTrailers>(),
      getMovieWatchProviders: getIt<GetMovieWatchProviders>(),
      getMovieImages: getIt<GetMovieImages>(),
      getOmdbRatings: getIt<GetOmdbRatings>(),
      isFavoriteUseCase: getIt<IsFavorite>(),
      addFavoriteUseCase: getIt<AddFavorite>(),
      removeFavoriteUseCase: getIt<RemoveFavorite>(),
    ),
  );

  getIt.registerFactory(
    () => SearchViewModel(
      searchMovies: getIt<SearchMovies>(),
    ),
  );

  getIt.registerLazySingleton(
    () => FavoritesViewModel(
      getFavoritesUseCase: getIt<GetFavorites>(),
      addFavoriteUseCase: getIt<AddFavorite>(),
      removeFavoriteUseCase: getIt<RemoveFavorite>(),
      isFavoriteUseCase: getIt<IsFavorite>(),
    ),
  );

  getIt.registerLazySingleton(
    () => ThemeViewModel(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton(
    () => NavigationViewModel(),
  );
}
