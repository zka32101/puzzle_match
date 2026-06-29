import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/theme.dart';

class FriendDuelScreen extends StatefulWidget {
  const FriendDuelScreen({super.key});

  @override
  State<FriendDuelScreen> createState() => _FriendDuelScreenState();
}

class _FriendDuelScreenState extends State<FriendDuelScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _mockFriends = [
    {'id': '1', 'name': 'User123', 'lastTime': 2.1, 'isOnline': true},
    {'id': '2', 'name': 'PuzzlePro', 'lastTime': 3.4, 'isOnline': false},
    {'id': '3', 'name': 'MathWiz', 'lastTime': 5.7, 'isOnline': true},
  ];

  void _createChallenge(String friendName) {
    final shareLink = 'https://puzzle-match.app/duel/abc123xyz';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('挑戦状を作成', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$friendName へ予想バトル挑戦！',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            SelectableText(
              shareLink,
              style: const TextStyle(color: AppTheme.primary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Share.share('$friendName と予想バトル！\n$shareLink\n#パズルマッチ');
              Navigator.pop(context);
            },
            child: const Text('📤 共有'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('👥 フレンド予想バトル')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'フレンド検索...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '友達に挑戦状を送ろう！',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._mockFriends.map((friend) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    friend['name']!.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  friend['name'],
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                subtitle: Row(
                  children: [
                    if (friend['isOnline']) ...[
                      const Icon(Icons.circle, size: 8, color: Colors.green),
                      const SizedBox(width: 4),
                      const Text(
                        'オンライン',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ] else ...[
                      const Icon(Icons.circle, size: 8, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'タイム: ${friend['lastTime']}秒',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _createChallenge(friend['name']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('挑戦', style: TextStyle(fontSize: 12)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
