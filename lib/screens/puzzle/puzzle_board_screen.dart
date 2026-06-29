import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_keypad.dart';
import 'result_screen.dart';

class PuzzleBoardScreen extends StatefulWidget {
  final Map<String, dynamic> puzzleData;

  const PuzzleBoardScreen({super.key, required this.puzzleData});

  @override
  State<PuzzleBoardScreen> createState() => _PuzzleBoardScreenState();
}

class _PuzzleBoardScreenState extends State<PuzzleBoardScreen> {
  late final Stopwatch _stopwatch;
  String _currentAnswer = '';
  int _attempts = 0;
  int _hintsUsed = 0;
  bool _isSubmitting = false;
  final List<Map<String, dynamic>> _inputLog = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _logAction(String action, String value) {
    _inputLog.add({
      'relativeTimeMs': _stopwatch.elapsedMilliseconds,
      'action': action,
      'value': value,
    });
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_currentAnswer.isNotEmpty) {
          _currentAnswer = _currentAnswer.substring(0, _currentAnswer.length - 1);
          _logAction('delete', '');
        }
      } else if (key == 'OK') {
        _logAction('submit', _currentAnswer);
        _submitAnswer();
      } else {
        _currentAnswer += key;
        _logAction('type', key);
      }
    });
  }

  Future<void> _submitAnswer() async {
    if (_currentAnswer.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _attempts++;
    });

    // モック判定（Firebase接続後はCloud Functions経由に変更）
    await Future.delayed(const Duration(milliseconds: 500));
    final elapsed = _stopwatch.elapsed.inMilliseconds / 1000;
    final isCorrect = _currentAnswer == '3' || _currentAnswer == '7';
    final result = {
      'isCorrect': isCorrect,
      'timeSeconds': elapsed,
      'globalRank': isCorrect ? 47 : 0,
      'closeCallLevel': isCorrect ? 0 : 2,
      'closeCallMessage': isCorrect ? '' : 'あと2手でした',
    };

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            puzzleNumber: widget.puzzleData['puzzle']?['number'] ?? 0,
            attempts: _attempts,
            inputLog: List.from(_inputLog),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = widget.puzzleData['puzzle'] ?? {};
    final question = puzzle['content']?['question'] ?? '';
    final expectedFormat = puzzle['content']?['expectedFormat'] ?? '数字を入力';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: _TimerWidget(stopwatch: _stopwatch),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QuestionCard(question: question),
                  const SizedBox(height: 32),
                  _AnswerDisplay(
                    answer: _currentAnswer,
                    hint: expectedFormat,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '試行: $_attempts回',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          CustomKeypad(
            onKeyTap: _onKeyTap,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _TimerWidget extends StatefulWidget {
  final Stopwatch stopwatch;

  const _TimerWidget({required this.stopwatch});

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {
  late final Stream<Duration> _stream;

  @override
  void initState() {
    super.initState();
    _stream = Stream.periodic(
      const Duration(milliseconds: 100),
      (_) => widget.stopwatch.elapsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _stream,
      builder: (context, snapshot) {
        final elapsed = snapshot.data ?? Duration.zero;
        final seconds = elapsed.inMilliseconds / 1000;
        return Text(
          '⏱ ${seconds.toStringAsFixed(1)}秒',
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _AnswerDisplay extends StatelessWidget {
  final String answer;
  final String hint;

  const _AnswerDisplay({required this.answer, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        answer.isEmpty ? hint : answer,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: answer.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
