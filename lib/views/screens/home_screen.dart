import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/viewmodel/movie_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieViewModel>().fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Movies'),
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text('Error: ${viewModel.errorMessage}'));
          }

          if (viewModel.movies.isEmpty) {
            return const Center(child: Text('No movies found.'));
          }

          return ListView.builder(
            itemCount: viewModel.movies.length,
            itemBuilder: (context, index) {
              final movie = viewModel.movies[index];
              return ListTile(
                leading: movie.posterPath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                        width: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.movie),
                title: Text(movie.title ?? 'No title'),
                subtitle: Text('Rating: ${movie.voteAverage}'),
                onTap: () {
                  // Navigate to detail screen if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
