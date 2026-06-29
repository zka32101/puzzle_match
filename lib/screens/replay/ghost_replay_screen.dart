import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/ghost_replay.dart';
import '../../utils/theme.dart';

class GhostReplayScreen extends StatefulWidget {
  final GhostReplay replay;
  final String puzzleQuestion;

  const GhostReplayScreen({
    super.key,
    required this.replay,
    required this.puzzleQuestion,
  });

  @override
  State<GhostReplayScreen> createState() => _GhostReplayScreenState();
}

class _GhostReplayScreenState extends State<GhostReplayScreen> {
  String _displayAnswer = '';
  int _currentLogIndex = 0;
  bool _isPlaying = false;
  bool _isFinished = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startReplay() {
    setState(() {
      _displayAnswer = '';
      _currentLogIndex = 0;
      _isPlaying = true;
      _isFinished = false;
    });

    final log = widget.replay.inputLog;
    if (log.isEmpty) {
      _finishReplay();
      return;
    }

    _scheduleNextAction(0);
  }

  void _scheduleNextAction(int index) {
    if (index >= widget.replay.inputLog.length) {
      _finishReplay();
      return;
    }

    final entry = widget.replay.inputLog[index];
    final delay = index == 0
        ? entry.relativeTimeMs
        : entry.relativeTimeMs - widget.replay.inputLog[index - 1].relativeTimeMs;

    _timer = Timer(Duration(milliseconds: delay.clamp(0, 5000)), () {
      if (!mounted) return;
      setState(() {
        _currentLogIndex = index;
        if (entry.action == 'type') {
          _displayAnswer += entry.value;
        } else if (entry.action == 'delete') {
          if (_displayAnswer.isNotEmpty) {
            _displayAnswer = _displayAnswer.substring(0, _displayAnswer.length - 1);
          }
        } else if (entry.action == 'submit') {
          _displayAnswer = entry.value;
        }
      });
      _scheduleNextAction(index + 1);
    });
  }

  void _finishReplay() {
    setState(() {
      _isPlaying = false;
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('👻 ${widget.replay.userName} のリプレイ'),
        actions: [
          Chip(
            backgroundColor: AppTheme.primary.withOpacity(0.2),
            label: Text(
              '${widget.replay.timeSeconds.toStringAsFixed(1)}秒 #${widget.replay.rank}位',
              style: const TextStyle(color: AppTheme.primary, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.puzzleQuestion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isFinished ? AppTheme.accent : AppTheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _isFinished
                          ? AppTheme.accent.withOpacity(0.1)
                          : AppTheme.cardBg,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isPlaying)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        if (_isPlaying) const SizedBox(width: 8),
                        Text(
                          _displayAnswer.isEmpty
                              ? (_isPlaying ? '入力中...' : '再生ボタンを押してください')
                              : _displayAnswer,
                          style: TextStyle(
                            color: _displayAnswer.isEmpty
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isFinished) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.replay.timeSeconds.toStringAsFixed(1)}秒でクリア！',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_currentLogIndex > 0 && widget.replay.inputLog.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_currentLogIndex}/${widget.replay.inputLog.length} アクション',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPlaying ? null : _startReplay,
                icon: Icon(_isFinished ? Icons.replay : Icons.play_arrow),
                label: Text(
                  _isPlaying
                      ? '再生中...'
                      : _isFinished
                          ? '🔄 もう一度'
                          : '▶ リプレイ再生',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isPlaying ? AppTheme.surface : AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
