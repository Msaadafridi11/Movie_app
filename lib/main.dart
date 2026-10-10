import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/movies/presentation/screens/splash_screen.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/home_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/search_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/theme_viewmodel.dart';
import 'package:movie_app/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Clean Architecture Dependency Injection
  await initInjection();

  runApp(const CineStreamApp());
}

/// Root Application Widget with MultiProvider and Dynamic Theme switching
class CineStreamApp extends StatelessWidget {
  const CineStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeViewModel>.value(
          value: getIt<ThemeViewModel>(),
        ),
        ChangeNotifierProvider<NavigationViewModel>.value(
          value: getIt<NavigationViewModel>(),
        ),
        ChangeNotifierProvider<FavoritesViewModel>.value(
          value: getIt<FavoritesViewModel>(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => getIt<HomeViewModel>(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => getIt<SearchViewModel>(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVm.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
