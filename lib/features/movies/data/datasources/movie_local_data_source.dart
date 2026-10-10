import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/errors/exceptions.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<List<MovieModel>> getFavorites();
  Future<void> addFavorite(MovieModel movie);
  Future<void> removeFavorite(int movieId);
  Future<bool> isFavorite(int movieId);

  // Cached Feed for Offline Fallback
  Future<List<MovieModel>> getCachedFeed();
  Future<void> cacheFeed(List<MovieModel> movies);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final SharedPreferences sharedPreferences;

  MovieLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<MovieModel>> getFavorites() async {
    try {
      final jsonStringList = sharedPreferences.getStringList(AppConstants.favoritesStorageKey);
      if (jsonStringList == null || jsonStringList.isEmpty) {
        return [];
      }
      return jsonStringList
          .map((item) => MovieModel.fromJson(json.decode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to read favorites from storage: $e');
    }
  }

  @override
  Future<void> addFavorite(MovieModel movie) async {
    try {
      final currentList = await getFavorites();
      if (!currentList.any((m) => m.id == movie.id)) {
        currentList.insert(0, movie);
        final encodedList = currentList.map((m) => json.encode(m.toJson())).toList();
        await sharedPreferences.setStringList(AppConstants.favoritesStorageKey, encodedList);
      }
    } catch (e) {
      throw CacheException('Failed to save favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    try {
      final currentList = await getFavorites();
      currentList.removeWhere((m) => m.id == movieId);
      final encodedList = currentList.map((m) => json.encode(m.toJson())).toList();
      await sharedPreferences.setStringList(AppConstants.favoritesStorageKey, encodedList);
    } catch (e) {
      throw CacheException('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      final currentList = await getFavorites();
      return currentList.any((m) => m.id == movieId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<MovieModel>> getCachedFeed() async {
    try {
      final jsonString = sharedPreferences.getString(AppConstants.cachedFeedKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final decoded = json.decode(jsonString) as List;
      return decoded
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheFeed(List<MovieModel> movies) async {
    try {
      final encoded = json.encode(movies.take(20).map((m) => m.toJson()).toList());
      await sharedPreferences.setString(AppConstants.cachedFeedKey, encoded);
    } catch (_) {
      // Best-effort cache write
    }
  }
}
