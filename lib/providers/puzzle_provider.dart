import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/puzzle.dart';
import 'auth_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final puzzleOfDayProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getPuzzleOfDay();
});

class PuzzleSessionNotifier extends StateNotifier<PuzzleSessionState> {
  PuzzleSessionNotifier() : super(const PuzzleSessionState());

  void startSession(String puzzleId, String startToken) {
    state = PuzzleSessionState(
      puzzleId: puzzleId,
      startToken: startToken,
      attempts: 0,
      currentInput: '',
    );
  }

  void updateInput(String input) {
    state = state.copyWith(currentInput: input);
  }

  void incrementAttempts() {
    state = state.copyWith(attempts: state.attempts + 1);
  }

  void reset() {
    state = const PuzzleSessionState();
  }
}

class PuzzleSessionState {
  final String? puzzleId;
  final String? startToken;
  final int attempts;
  final String currentInput;

  const PuzzleSessionState({
    this.puzzleId,
    this.startToken,
    this.attempts = 0,
    this.currentInput = '',
  });

  PuzzleSessionState copyWith({
    String? puzzleId,
    String? startToken,
    int? attempts,
    String? currentInput,
  }) {
    return PuzzleSessionState(
      puzzleId: puzzleId ?? this.puzzleId,
      startToken: startToken ?? this.startToken,
      attempts: attempts ?? this.attempts,
      currentInput: currentInput ?? this.currentInput,
    );
  }
}

final puzzleSessionProvider =
    StateNotifierProvider<PuzzleSessionNotifier, PuzzleSessionState>((ref) {
  return PuzzleSessionNotifier();
});
