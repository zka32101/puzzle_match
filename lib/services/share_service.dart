import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareResult({
    required int rank,
    required double timeSeconds,
    required int puzzleNumber,
    required bool isCorrect,
    required String aiCommentary,
    required int closeCallLevel,
  }) async {
    final emoji = isCorrect ? '🎉' : '😢';
    final closeCallStars = '★' * closeCallLevel + '☆' * (3 - closeCallLevel);

    String text;
    if (isCorrect) {
      text = '''$emoji パズルマッチ #$puzzleNumber
🏆 ${rank}位 / ${timeSeconds.toStringAsFixed(1)}秒

🤖 $aiCommentary

#パズルマッチ #puzzlematch''';
    } else {
      text = '''$emoji パズルマッチ #$puzzleNumber
惜しい度: $closeCallStars

🤖 $aiCommentary

#パズルマッチ #puzzlematch''';
    }

    await Share.share(text);
  }
}
