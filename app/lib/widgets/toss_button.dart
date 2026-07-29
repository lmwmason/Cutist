import 'package:flutter/material.dart';

import '../theme/toss_tokens.dart';

enum TossButtonVariant { fill, weak }

class TossButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TossButtonVariant variant;
  final IconData? icon;
  final Color? accent;

  const TossButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TossButtonVariant.fill,
    this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = accent ?? TossColors.primary;

    final Color background;
    final Color foreground;
    switch (variant) {
      case TossButtonVariant.fill:
        background = baseColor;
        foreground = TossColors.onPrimary;
        break;
      case TossButtonVariant.weak:
        background = accent == null
            ? TossColors.weakBackground
            : baseColor.withValues(alpha: 0.1);
        foreground = accent ?? TossColors.weakForeground;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: TossColors.surface,
          disabledForegroundColor: TossColors.muted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TossRadius.buttonXLarge),
          ),
          textStyle: TossTextStyles.buttonXLargeBase,
          elevation: 0,
        ),
        child: icon == null
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: TossSpacing.sm),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
