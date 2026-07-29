import 'package:flutter/material.dart';

import '../theme/toss_tokens.dart';

class CycleDots extends StatelessWidget {
  final int totalCycles;
  final int cyclesUntilLongBreak;
  final Color accent;

  const CycleDots({
    super.key,
    required this.totalCycles,
    required this.cyclesUntilLongBreak,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalCycles.clamp(1, 12);
    final completed = (total - cyclesUntilLongBreak).clamp(0, total);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final filled = index < completed;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TossSpacing.xs / 2),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? accent : TossColors.border,
            ),
          ),
        );
      }),
    );
  }
}
