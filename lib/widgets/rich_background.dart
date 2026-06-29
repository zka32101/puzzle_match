import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// アニメーションする深宇宙風グラデーション背景＋浮遊オーブ
class RichBackground extends StatefulWidget {
  final Widget child;
  const RichBackground({super.key, required this.child});

  @override
  State<RichBackground> createState() => _RichBackgroundState();
}

class _RichBackgroundState extends State<RichBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ベースグラデーション
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF11102A),
                Color(0xFF0F0F1A),
                Color(0xFF1A1130),
              ],
            ),
          ),
          child: SizedBox.expand(),
        ),
        // 浮遊する光のオーブ
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _OrbPainter(_ctrl.value),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final orbs = [
      _Orb(AppTheme.primary, 0.2, 0.15, 160, 0.0),
      _Orb(AppTheme.secondary, 0.85, 0.25, 130, 0.33),
      _Orb(const Color(0xFF42A5F5), 0.7, 0.8, 180, 0.66),
      _Orb(AppTheme.accent, 0.15, 0.85, 110, 0.5),
    ];
    for (final o in orbs) {
      final phase = (t + o.offset) * 2 * math.pi;
      final dx = o.x * size.width + math.sin(phase) * 30;
      final dy = o.y * size.height + math.cos(phase) * 30;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [o.color.withOpacity(0.22), o.color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: o.radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(Offset(dx, dy), o.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

class _Orb {
  final Color color;
  final double x, y, radius, offset;
  _Orb(this.color, this.x, this.y, this.radius, this.offset);
}

/// グロー付きグラデーションカード
class GlowCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradient;
  final Color glow;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GlowCard({
    super.key,
    required this.child,
    required this.gradient,
    required this.glow,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glow.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: glow.withOpacity(0.28),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
