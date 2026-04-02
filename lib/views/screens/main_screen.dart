import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/viewmodel/main_viewmodel.dart';
import 'package:movie_app/views/screens/home_screen.dart';
import 'package:movie_app/views/screens/search_screen.dart';
import 'package:movie_app/views/screens/favorites_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      const FavoritesScreen(),
      const Scaffold(body: Center(child: Text('Profile', style: TextStyle(color: Colors.white)))),
    ];

    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: IndexedStack(
            index: viewModel.currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: viewModel.currentIndex,
            onTap: (index) => viewModel.setIndex(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.redAccent,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border_outlined), label: 'Favorites'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
