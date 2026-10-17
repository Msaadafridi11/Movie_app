import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/global_error_widget.dart';
import 'package:movie_app/features/movies/presentation/screens/splash_screen.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/home_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/search_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/theme_viewmodel.dart';
import 'package:movie_app/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive edge-to-edge transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Global Error Handling: Capture framework errors and prevent red screen crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[Global FlutterError] ${details.exceptionAsString()}');
  };

  // Global Error Handling: Capture uncaught asynchronous platform dispatch errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[Global PlatformDispatcher Error] $error');
    return true; // Mark as handled
  };

  // Replace raw technical red/grey crash screens with a friendly user error view
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalFriendlyErrorWidget(details: details);
  };

  // Load environment variables (.env) if present
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[Environment] .env file not found or failed to load: $e. Using fallback configuration.');
  }

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
