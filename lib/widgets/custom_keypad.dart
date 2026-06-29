import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomKeypad extends StatelessWidget {
  final void Function(String key) onKeyTap;
  final bool isLoading;

  const CustomKeypad({super.key, required this.onKeyTap, this.isLoading = false});

  static const List<List<String>> _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
    ['OK'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: _rows.map((row) {
          return Row(
            children: row.map((key) {
              return Expanded(
                flex: key == 'OK' ? 3 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _KeyButton(
                    label: key,
                    onTap: isLoading ? null : () => onKeyTap(key),
                    isAction: key == 'OK' || key == '⌫',
                    isPrimary: key == 'OK',
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isAction;
  final bool isPrimary;

  const _KeyButton({
    required this.label,
    required this.onTap,
    required this.isAction,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isPrimary) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
    } else if (isAction) {
      bgColor = AppTheme.cardBg;
      textColor = AppTheme.secondary;
    } else {
      bgColor = AppTheme.cardBg;
      textColor = AppTheme.textPrimary;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: isPrimary ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
