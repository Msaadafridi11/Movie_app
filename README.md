# 🎬 Movie App (CineFlix)

A modern, high-performance Flutter movie application powered by **The Movie Database (TMDB) API**. Built using **Clean Architecture**, **MVVM (Model-View-ViewModel)** pattern, and **Provider** state management.

---

## 🚀 Features

- **🔥 Trending & Featured Carousel**: Discover daily trending blockbusters with auto-scrolling hero banners.
- **🌟 Curated Movie Categories**: Explore Popular, Top Rated, and Upcoming movie feeds.
- **🔍 Instant Search**: Search through thousands of movies with real-time debounced queries.
- **🎭 Rich Movie Details**:
  - Immersive backdrop & poster art
  - Interactive YouTube trailer playback
  - Ratings, genres, runtime, release date, and comprehensive synopsis
  - Cast & Crew profile cards
  - Similar movies recommendation engine
- **❤️ Local Watchlist & Favorites**: Save favorite movies locally using persistent storage (`shared_preferences`).
- **📶 Network Connectivity Awareness**: Real-time connection status monitoring.
- **✨ Shimmer Loading & Smooth Caching**: Elegant skeleton loaders and cached network images for seamless offline/poor network handling.
- **🎨 Modern Dark Aesthetic**: Custom themes with Google Fonts typography and responsive layouts.

---

## 🏛️ Architecture & Folder Structure

The project strictly follows **Clean Architecture** combined with **MVVM** and **Provider**:

```text
lib/
├── core/
│   ├── constants/             # API constants, endpoints, and asset paths
│   │   ├── api_constants.dart
│   │   ├── api_keys.dart           # Ignored in git (.gitignore)
│   │   └── api_keys.example.dart   # Template for API keys
│   ├── errors/                # Failure & Exception classes (dartz Either)
│   ├── network/               # Dio HTTP client, interceptors & network checker
│   ├── theme/                 # App colors, dark/light themes & typography
│   ├── utils/                 # Helpers, debounce utilities & formatters
│   └── widgets/               # Reusable UI widgets (loaders, error views, buttons)
│
├── features/
│   └── movies/
│       ├── data/              # Data Layer: TMDB remote API & local storage
│       │   ├── datasources/   # Remote & Local datasources
│       │   ├── models/        # JSON serialization & entity mapping
│       │   └── repositories/  # Repository implementations
│       │
│       ├── domain/            # Domain Layer: Pure business logic (framework-agnostic)
│       │   ├── entities/      # Core business objects
│       │   ├── repositories/  # Repository contracts (abstract classes)
│       │   └── usecases/      # Single-responsibility use cases
│       │
│       └── presentation/      # Presentation Layer: MVVM UI & State
│           ├── providers/     # ViewModels extending ChangeNotifier
│           ├── screens/       # Views (Home, Details, Search, Watchlist, etc.)
│           └── widgets/       # Feature-specific UI components
│
├── injection_container.dart   # Dependency injection setup via GetIt
└── main.dart                  # App entry point & Provider registration
```

---

## 📦 Key Packages Used

| Package | Purpose |
|---|---|
| [`provider`](https://pub.dev/packages/provider) | State management following the MVVM pattern |
| [`dio`](https://pub.dev/packages/dio) | Robust HTTP networking with logging and query interceptors |
| [`get_it`](https://pub.dev/packages/get_it) | Service locator for clean dependency injection |
| [`dartz`](https://pub.dev/packages/dartz) | Functional error handling using `Either<Failure, Success>` |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Custom typography and font styles |
| [`cached_network_image`](https://pub.dev/packages/cached_network_image) | High-performance image caching with fallback placeholders |
| [`shimmer`](https://pub.dev/packages/shimmer) | Skeleton loading animations |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Persistent local storage for user favorites / watchlist |
| [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) | Real-time network connectivity monitoring |
| [`youtube_player_flutter`](https://pub.dev/packages/youtube_player_flutter) / [`youtube_player_iframe`](https://pub.dev/packages/youtube_player_iframe) | Seamless YouTube trailer video playback |
| [`url_launcher`](https://pub.dev/packages/url_launcher) | External browser and social links handler |

---

## 🔑 Setup & TMDB API Key Configuration

To run this application, you will need a free API key from [The Movie Database (TMDB)](https://www.themoviedb.org/).

### 1. Get an API Key
1. Register or log into [The Movie Database](https://www.themoviedb.org/).
2. Navigate to **Settings > API**.
3. Generate a free **API Key (v3 auth)**.

### 2. Configure the Key in the Project

Choose either of the two methods below:

#### Method A: Using `api_keys.dart` (Recommended)
1. In the `lib/core/constants/` directory, create `api_keys.dart` by copying `api_keys.example.dart`:
   ```bash
   cp lib/core/constants/api_keys.example.dart lib/core/constants/api_keys.dart
   ```
2. Open `lib/core/constants/api_keys.dart` and paste your TMDB API key:
   ```dart
   class ApiKeys {
     static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
   }
   ```
   *(Note: `api_keys.dart` is included in `.gitignore` to protect your secrets.)*

#### Method B: Command Line `--dart-define`
Run the app passing your API key directly via the command line:
```bash
flutter run --dart-define=TMDB_API_KEY=YOUR_TMDB_API_KEY_HERE
```

---

## 🏃 How to Run the App

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Msaadafridi11/Movie_app.git
   cd Movie_app
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify analyzer status:**
   ```bash
   flutter analyze
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📱 Screenshots

| Home & Trending | Movie Details | Search & Filter | Watchlist |
|:---:|:---:|:---:|:---:|
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

---

## 👨‍💻 Author

Developed by **Saad Afridi** ❤️ in Flutter
