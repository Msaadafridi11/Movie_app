import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/viewmodel/movie_viewmodel.dart';
import 'package:movie_app/data/repositories/movie_repository.dart';
import 'package:movie_app/data/services/movie_api_service.dart';
import 'package:movie_app/views/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MovieViewModel(
            MovieRepository(MovieApiService()),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Movie App MVVM',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
