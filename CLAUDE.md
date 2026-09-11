# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**puzzle_match** is a Flutter-based daily puzzle game with AI commentary and world rankings. The app runs on iOS, Android, Web, Windows, macOS, and Linux, with a backend powered by Firebase and Cloud Functions.

**Key Features:**
- Daily puzzle challenges with AI-generated commentary
- Global leaderboard with country-level statistics
- Ghost replay system for competing against past solutions
- Multi-platform support (iOS, Android, Web, Desktop)
- Firebase-based authentication and data persistence

## Architecture

### State Management: Riverpod
The app uses **Flutter Riverpod** (v2.5.1) for dependency injection and state management. Key patterns:

- **Providers**: Immutable references to shared state (e.g., `apiServiceProvider`, `puzzleOfDayProvider`)
- **FutureProviders**: Async data fetching (e.g., `puzzleOfDayProvider` for daily puzzle data)
- **StateNotifiers**: Mutable state with defined transitions (e.g., `PuzzleSessionNotifier`)
- All providers defined in `/lib/providers/` - currently: `auth_provider.dart`, `leaderboard_provider.dart`, `puzzle_provider.dart`

### Backend Architecture

**Firebase Services** (`/lib/services/firebase_service.dart`):
- Authentication (anonymous + Google Sign-In)
- Cloud Firestore (user profiles, game history, leaderboard snapshots)
- Firebase Analytics
- Cloud Messaging (push notifications)

**REST API Services** (`/lib/services/api_service.dart`):
- Base URL: `https://us-central1-puzzle-match-app.cloudfunctions.net/v1`
- Endpoints: `getPuzzleOfDay`, leaderboard queries
- Header-based token authentication with Bearer scheme
- Dart HTTP client with JSON serialization

**Cloud Functions** (`/functions/`):
- Node.js/TypeScript backend for puzzle generation and AI commentary
- REST endpoints exposed to Flutter client

### UI Architecture
- **Screens** (`/lib/screens/`): Feature-based screen organization
  - `home/` - Main landing screen
  - `auth/` - Authentication flows
  - `puzzle/` - Puzzle solving interface
  - `leaderboard/` - Rankings and statistics
  - `replay/` - Ghost replay viewing
  - `rival/` - Head-to-head comparisons
  - `v2/` - UI iteration screens
- **Widgets** (`/lib/widgets/`): Reusable components
- **Models** (`/lib/models/`): Data classes (Puzzle, User, LeaderboardEntry, etc.)
- **Utils** (`/lib/utils/`): Theme, constants, helper functions

### Data Models

Core models in `/lib/models/`:
- `puzzle.dart` - Puzzle definition and metadata
- `user.dart` - User profile and statistics
- `leaderboard_entry.dart` - Ranking entry with country/stats
- `solution.dart` - Puzzle solution and timing
- `ghost_replay.dart` - Recorded solution for replay
- `season.dart` - Seasonal competition context
- `game_modifier.dart` - Rules/modifiers for puzzle variations
- `drag_puzzle.dart` - Sliding puzzle mechanics

## Build & Development Commands

### Flutter Setup
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Clean build artifacts
flutter clean
```

### Building

**Debug (Development)**
```bash
flutter run                    # Run on connected device/emulator
flutter run -d chrome          # Web browser
flutter run -d windows         # Windows desktop
flutter run -d macos           # macOS desktop
flutter run -d linux           # Linux desktop
```

**Release Builds**
```bash
flutter build apk --release    # Android (GitHub workflow triggered by tags v*)
flutter build ios --release    # iOS
flutter build appbundle        # Android App Bundle
flutter build web --release    # Web
flutter build windows --release # Windows
flutter build macos --release  # macOS
flutter build linux --release  # Linux
```

### Code Quality

**Linting**
```bash
flutter analyze                 # Check for lints and errors
# Configured in analysis_options.yaml using package:flutter_lints
```

**Testing**
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test file
flutter test --verbose         # Verbose output
```

**Formatting** (optional, not currently enforced)
```bash
dart format lib/               # Format Dart files
dart format lib/ --set-exit-if-changed  # Check without modifying
```

## Key Configuration & Constants

- **API Base URL**: `https://us-central1-puzzle-match-app.cloudfunctions.net/v1`
- **Ghost Retention**: 7 days (stale ghosts removed)
- **Leaderboard Cache**: 30 seconds
- **AI Commentary Cache**: 24 hours
- **Minimum Solve Time**: 0.5 seconds
- **Max Hints**: 3 per puzzle
- **App Name**: パズルマッチ (Puzzle Match)

See `/lib/utils/constants.dart` for all configuration values.

## Development Workflow

### Adding Features
1. **Define providers** in `providers/` for state and API calls
2. **Create screens** in `screens/` using Riverpod's `ref.watch()`
3. **Add models** in `models/` with `copyWith()` and `toJson()/fromJson()`
4. **Create widgets** in `widgets/` for reusable components
5. **Update services** (`services/`) if new API endpoints needed

### State Flow Example
```
UI Layer (Screens)
  ↓ reads
Riverpod Provider (e.g., puzzleOfDayProvider)
  ↓ depends on
Service Layer (apiServiceProvider → ApiService)
  ↓ calls
Backend (REST API / Firebase)
```

### Firebase Authentication
- Anonymous sign-in for first-time users
- Google Sign-In integration (package: `google_sign_in`)
- Token stored and passed in API request headers
- Auth state changes monitored via `authStateChanges` stream

## Testing

- Unit and widget tests in `/test/`
- `flutter test widget_test.dart` for specific tests
- No specific test framework beyond Flutter's built-in `flutter_test`
- Mock Firebase/API services as needed for unit tests

## CI/CD

- **Deploy Workflow** (`.github/workflows/deploy.yml`): Triggered on version tags (`v*`)
  - Builds APK for Android release
  - Can be extended for iOS/Web deployments
- **Claude Code Workflow** (`.github/workflows/claude.yml`): Auto-triggered on issues and PRs mentioning `@claude`

## Dependencies Highlights

- **flutter_riverpod**: State management and DI
- **firebase_***: Firebase services (auth, Firestore, messaging, analytics)
- **google_sign_in**: OAuth integration
- **http**: REST API calls
- **shared_preferences**: Local key-value storage
- **flutter_secure_storage**: Secure token storage
- **intl**: Internationalization (for date/time)
- **flutter_animate**: Animation utilities
- **uuid**: ID generation
- **share_plus**: Native sharing

## Common Development Patterns

### Accessing a Provider in Widgets
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);
    return data.when(
      data: (result) => Text('$result'),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### Updating State via StateNotifier
```dart
// In a StateNotifier subclass
void updatePuzzleInput(String input) {
  state = state.copyWith(currentInput: input);
}

// From UI
ref.read(puzzleSessionProvider.notifier).updatePuzzleInput('new input');
```

### Calling API with Authentication
The `ApiService` automatically adds Bearer token to request headers when initialized with an `authToken`.

## Debugging Tips

- Use `flutter run --verbose` for detailed logs
- Check Firebase Console for backend errors
- Use Dart DevTools: `flutter pub global activate devtools && devtools`
- Monitor Riverpod state with `ref.watch()` watches in the build tree
