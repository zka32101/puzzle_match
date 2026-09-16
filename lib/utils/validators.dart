class InputValidators {
  static bool isValidUserId(String userId) {
    return userId.isNotEmpty && userId.length <= 128;
  }

  static bool isValidPuzzleId(String puzzleId) {
    return puzzleId.isNotEmpty && puzzleId.length <= 50;
  }

  static bool isValidAnswer(String answer) {
    return answer.isNotEmpty && answer.length <= 1000;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidToken(String token) {
    return token.isNotEmpty && token.length >= 10;
  }

  static String? validatePuzzleInput(String input) {
    if (input.isEmpty) {
      return 'Puzzle ID cannot be empty';
    }
    if (input.length > 50) {
      return 'Puzzle ID too long';
    }
    return null;
  }

  static String? validateAnswerInput(String answer) {
    if (answer.isEmpty) {
      return 'Answer cannot be empty';
    }
    if (answer.length > 1000) {
      return 'Answer too long';
    }
    return null;
  }
}
