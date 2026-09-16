# パズルマッチ - puzzle_match

A daily puzzle game with AI commentary and global leaderboards, built with Flutter and Firebase.

**Languages:** Dart, TypeScript (Cloud Functions) | **Platforms:** iOS, Android, Web, Windows, macOS, Linux

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development Setup](#development-setup)
- [Architecture](#architecture)
- [Security](#security)
- [Contributing](#contributing)
- [Documentation](#documentation)

---

## Features

✨ **Core Gameplay**
- Daily puzzle challenges with fresh content
- AI-generated commentary using Cloud Functions
- Puzzle solution timing and replay system
- Ghost replay feature for comparing solutions

🌍 **Social & Leaderboards**
- Global leaderboard with country-level statistics
- User profiles and statistics
- Seasonal competitions
- Share puzzle solutions

🔐 **Security**
- Firebase Authentication (anonymous + Google Sign-In)
- Firestore database with security rules
- Encrypted token storage
- Input validation and rate limiting
- Security event logging

🎨 **UI/UX**
- Dark theme optimized
- Multi-platform responsive design
- Smooth animations
- Japanese localization

---

## Quick Start

### Prerequisites

- **Flutter**: 3.12+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart**: 3.12+ (included with Flutter)
- **Firebase Account**: For backend services
- **Git**: For version control

### 1. Clone Repository

```bash
git clone https://github.com/zka32101/puzzle_match.git
cd puzzle_match
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android and iOS apps to your project
3. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Enable Firebase services:
   - Authentication (Anonymous + Google Sign-In)
   - Firestore Database
   - Cloud Functions (for AI commentary)

### 4. Run Application

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d macos           # macOS
flutter run -d linux           # Linux
```

### 5. Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop (Windows/macOS/Linux)
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

---

## Project Structure

```
puzzle_match/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/                  # UI screens
│   │   ├── home/                 # Home screen
│   │   ├── auth/                 # Authentication flows
│   │   ├── puzzle/               # Puzzle solving interface
│   │   ├── leaderboard/          # Rankings & statistics
│   │   ├── replay/               # Ghost replay viewer
│   │   ├── rival/                # Head-to-head comparison
│   │   └── v2/                   # UI iterations
│   ├── widgets/                  # Reusable components
│   ├── models/                   # Data classes (Puzzle, User, etc.)
│   ├── providers/                # Riverpod state management
│   ├── services/                 # API & Firebase services
│   │   ├── api_service.dart      # REST API client
│   │   ├── firebase_service.dart # Firebase operations
│   │   ├── security_logger.dart  # Security event logging
│   │   └── rate_limiter.dart     # Rate limiting
│   └── utils/                    # Utilities & helpers
│       ├── constants.dart        # App configuration
│       ├── theme.dart            # Dark theme
│       ├── validators.dart       # Input validation
│       ├── json_utils.dart       # Safe JSON parsing
│       └── security_logger.dart  # Security logging
├── test/
│   ├── security_test.dart        # Security tests
│   └── widget_test.dart          # Widget tests
├── .github/
│   └── workflows/                # CI/CD pipelines
├── firestore.rules               # Database security rules
├── CLAUDE.md                     # Claude Code guidance
├── SECURITY.md                   # Security architecture
├── analysis_options.yaml         # Linter configuration
└── pubspec.yaml                  # Dependencies & metadata
```

---

## Development Setup

### Code Quality

```bash
# Run linter
flutter analyze

# Format code (optional)
dart format lib/

# Run tests
flutter test
flutter test test/security_test.dart
```

### Debugging

```bash
# Verbose output
flutter run --verbose

# Debug specific file
flutter run test/widget_test.dart --verbose

# Launch Dart DevTools
flutter pub global activate devtools
devtools
```

### Hot Reload

Press `r` in the console during `flutter run` to hot reload changes instantly.

---

## Architecture

### State Management: Riverpod

The app uses **Flutter Riverpod** for dependency injection and state management:

```dart
// Define provider
final puzzleProvider = FutureProvider<Puzzle>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getPuzzleOfDay();
});

// Use in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = ref.watch(puzzleProvider);
    return puzzle.when(
      data: (p) => Text(p.title),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### Backend Services

**REST API** (Cloud Functions)
- Base URL: `https://us-central1-puzzle-match-app.cloudfunctions.net/v1`
- Endpoints: `getPuzzleOfDay`, `submitSolution`, `getLeaderboard`, `generateAICommentary`
- Authentication: Bearer token in `Authorization` header

**Firebase Services**
- **Authentication**: Anonymous + Google Sign-In
- **Firestore**: User profiles, game history, leaderboard
- **Cloud Functions**: AI commentary generation
- **Analytics**: User behavior tracking

### Data Models

All models support JSON serialization:

```dart
final puzzle = Puzzle.fromJson(json);
final json = puzzle.toJson();
```

See `lib/models/` for full list.

---

## Security

🔒 **This project implements comprehensive security measures:**

- **Authentication**: Firebase Auth with token management
- **Database Security**: Firestore rules enforce user-level access control
- **Input Validation**: All user inputs validated before API submission
- **Rate Limiting**: Client-side request throttling
- **Safe JSON Parsing**: Error handling for malformed responses
- **Secure Storage**: Sensitive tokens stored via `flutter_secure_storage`
- **HTTPS/TLS**: All network communication encrypted
- **Security Logging**: Track authentication, validation, and suspicious activity

📚 **See [SECURITY.md](SECURITY.md) for detailed security architecture and best practices.**

---

## Contributing

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable/function names
- Write comments for non-obvious logic
- Prefer immutable data classes

### Before Submitting PR

1. ✅ Run `flutter analyze` - no errors
2. ✅ Run `flutter test` - all tests pass
3. ✅ Check input validation - all user inputs validated
4. ✅ Review security - no hardcoded secrets
5. ✅ Update `CHANGELOG.md` if applicable
6. ✅ Rebase onto `main` branch

### Commit Messages

Use clear, descriptive commit messages:

```
feat: add puzzle sharing feature
fix: correct leaderboard sort order
security: implement rate limiting
docs: update setup instructions
refactor: simplify puzzle model
test: add edge case tests for validators
```

---

## Documentation

📖 **Important Documentation Files:**

- **[CLAUDE.md](CLAUDE.md)** - Architecture details, development workflow, and patterns for Claude Code instances
- **[SECURITY.md](SECURITY.md)** - Complete security architecture, best practices, and incident response
- **[pubspec.yaml](pubspec.yaml)** - All dependencies with versions
- **[analysis_options.yaml](analysis_options.yaml)** - Lint rules configuration

---

## Key Configuration

| Setting | Value |
|---------|-------|
| API Base URL | `https://us-central1-puzzle-match-app.cloudfunctions.net/v1` |
| Ghost Retention | 7 days |
| Leaderboard Cache | 30 seconds |
| AI Commentary Cache | 24 hours |
| Min Solve Time | 0.5 seconds |
| Max Hints | 3 per puzzle |
| App Name | パズルマッチ |

---

## Troubleshooting

### Common Issues

**Firebase initialization fails**
- Verify Firebase config files are in correct directories
- Check Firebase project settings match app configuration

**Widgets not updating after model changes**
- Ensure using Riverpod `ref.watch()` for reactive updates
- Check model `copyWith()` creates new instance

**Tests fail with "platform exception"**
- Run `flutter clean` then `flutter pub get`
- Verify test data and mock setup

**Hot reload not working**
- Press `r` in console, not `R` (full restart)
- Some changes require full app restart

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Guide](https://riverpod.dev)
- [Firebase Console](https://console.firebase.google.com)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-top-10/)

---

## License

[Specify your license here]

## Support

For issues and questions:
1. Check [SECURITY.md](SECURITY.md) for security concerns
2. Check [CLAUDE.md](CLAUDE.md) for architecture details
3. Open a GitHub issue with reproduction steps
4. Follow project code of conduct

---

**Last Updated:** 2026-09-16  
**Status:** Active Development  
**Maintained by:** puzzle_match team
