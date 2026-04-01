import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/data/services/movie_api_service.dart';
import 'package:movie_app/data/repositories/movie_repository.dart';
import 'package:movie_app/viewmodel/movie_viewmodel.dart';
import 'package:movie_app/viewmodel/main_viewmodel.dart';
import 'package:movie_app/viewmodel/search_viewmodel.dart';
import 'package:movie_app/viewmodel/video_viewmodel.dart';
import 'package:movie_app/views/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DioClient>(
          create: (_) => DioClient(),
        ),
        ProxyProvider<DioClient, MovieApiService>(
          update: (_, dioClient, __) => MovieApiService(dioClient),
        ),
        ProxyProvider<MovieApiService, MovieRepository>(
          update: (_, apiService, __) => MovieRepository(apiService),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<MainViewModel>(
                create: (_) => MainViewModel(),
              ),
              ChangeNotifierProvider<MovieViewModel>(
                create: (_) => MovieViewModel(
                  context.read<MovieRepository>(),
                ), 
              ),
              ChangeNotifierProvider<SearchViewModel>(
                create: (_) => SearchViewModel(
                  context.read<MovieRepository>(),
                ),
              ),
              ChangeNotifierProvider<VideoViewModel>(
                create: (_) => VideoViewModel(
                  context.read<MovieRepository>(),
                ),
              ),
            ],
            child: MaterialApp(
              title: 'Movie Streaming UI',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF141414), // Netflix style black
                primaryColor: Colors.redAccent,
                colorScheme: const ColorScheme.dark(
                  primary: Colors.redAccent,
                  secondary: Colors.redAccent,
                  surface: Color(0xFF1F1F1F),
                ),
                textTheme: GoogleFonts.interTextTheme(
                  ThemeData.dark().textTheme,
                ).apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF141414),
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              home: const MainScreen(),
            ),
          );
        },
      ),
    );
  }
}
