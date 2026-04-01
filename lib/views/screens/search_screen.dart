import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/viewmodel/search_viewmodel.dart';
import 'package:movie_app/views/widgets/movie_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use read for the initial callback to avoid tight coupling in build method
    final viewModel = context.read<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (query) {
                // Implementing simple debounce behavior could be added here later
                viewModel.searchMovies(query);
              },
              decoration: InputDecoration(
                hintText: 'Search movies, TV shows...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2B2B2B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<SearchViewModel>(
                builder: (context, searchVM, child) {
                  if (searchVM.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                  }
                  if (searchVM.errorMessage != null) {
                    return Center(child: Text('Error: ${searchVM.errorMessage}'));
                  }
                  if (searchVM.searchedMovies.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Search for a movie',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  // Display search results
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: searchVM.searchedMovies.length,
                    itemBuilder: (context, index) {
                      return MovieCard(movie: searchVM.searchedMovies[index], width: double.infinity);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
