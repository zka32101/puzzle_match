import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/streak_insurance.dart';
import '../../utils/theme.dart';
import '../../widgets/rich_background.dart';

class StreakInsuranceScreen extends StatefulWidget {
  const StreakInsuranceScreen({super.key});

  @override
  State<StreakInsuranceScreen> createState() => _StreakInsuranceScreenState();
}

class _StreakInsuranceScreenState extends State<StreakInsuranceScreen> {
  bool _isLoading = true;
  late StreakInsurance _insurance;

  @override
  void initState() {
    super.initState();
    _loadInsuranceData();
  }

  Future<void> _loadInsuranceData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _insurance = _mockInsurance();
      _isLoading = false;
    });
  }

  StreakInsurance _mockInsurance() => StreakInsurance(
    userId: 'user1',
    isActive: true,
    expiresAt: DateTime.now().add(const Duration(days: 25)),
    usesRemaining: 1,
    totalUses: 1,
  );

  void _purchaseInsurance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎯 RevenueCat統合: 月¥120の購読を開始しました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('🛡 ストリーク保険'),
      ),
      body: RichBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InsuranceStatusCard(insurance: _insurance).animate().fadeIn(),
                  const SizedBox(height: 24),
                  _InsurancePitchCard().animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),
                  if (!_insurance.isActive)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [AppTheme.secondary, Color(0xFFFF7043)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondary.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _purchaseInsurance,
                          icon: const Icon(Icons.shopping_bag, size: 22),
                          label: const Text(
                            '月¥120で購読開始',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                ],
              ),
      ),
    );
  }
}

class _InsuranceStatusCard extends StatelessWidget {
  final StreakInsurance insurance;

  const _InsuranceStatusCard({required this.insurance});

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: insurance.isActive
          ? const [Color(0xFF1A3A2E), Color(0xFF0D2B25)]
          : const [Color(0xFF3A1B2E), Color(0xFF16213E)],
      glow: insurance.isActive ? AppTheme.success : AppTheme.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ステータス',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (insurance.isActive ? AppTheme.success : AppTheme.warning)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  insurance.isActive ? '✓ 有効' : '未購入',
                  style: TextStyle(
                    color: insurance.isActive ? AppTheme.success : AppTheme.warning,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (insurance.isActive && insurance.expiresAt != null) ...[
            const Text(
              '次回更新日',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              '${insurance.expiresAt!.year}年${insurance.expiresAt!.month}月${insurance.expiresAt!.day}日',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '残り使用回数: ${insurance.usesRemaining}/${insurance.totalUses}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsurancePitchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: const [Color(0xFF1B3A4B), Color(0xFF16213E)],
      glow: AppTheme.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'ストリークが続かない時に',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '月額¥120でストリーク保険に加入。もし連続記録を途切れさせてしまった時、1回まで復活させられます。毎月1回の使用が可能。',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
          ),
          SizedBox(height: 12),
          Text(
            '💡 ヒント：毎日プレイできない日があれば、保険があると心強い',
            style: TextStyle(color: AppTheme.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
