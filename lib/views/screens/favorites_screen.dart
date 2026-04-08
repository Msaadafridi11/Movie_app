import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/viewmodel/favorite_viewmodel.dart';
import 'package:movie_app/views/widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Netflix black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MY LIST',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: Consumer<FavoriteViewModel>(
        builder: (context, favoriteVM, child) {
          if (favoriteVM.favoriteMovies.isEmpty) {
            return _buildEmptyState();
          }

          return SafeArea(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
              ),
              itemCount: favoriteVM.favoriteMovies.length,
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: favoriteVM.favoriteMovies[index],
                  width: double.infinity,
                  margin: EdgeInsets.zero, // Fixes the grid layout misalignment
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.format_list_bulleted_rounded,
              size: 80,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your List is Empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              'Save shows and movies to keep track of what you want to watch next.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
