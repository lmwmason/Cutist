import 'package:flutter/material.dart';

import '../core/study_state.dart';
import '../theme/toss_tokens.dart';

Color accentForState(StudyState state) {
  switch (state) {
    case StudyState.idle:
      return TossColors.pausedAccent;
    case StudyState.focus:
      return TossColors.focusAccent;
    case StudyState.shortBreak:
      return TossColors.breakAccent;
    case StudyState.longBreak:
      return TossColors.longBreakAccent;
    case StudyState.paused:
      return TossColors.pausedAccent;
  }
}

class StateBadge extends StatelessWidget {
  final StudyState state;

  const StateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final accent = accentForState(state);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossSpacing.lg,
        vertical: TossSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(TossRadius.buttonSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: TossSpacing.sm),
          Text(
            state.label,
            style: TossTextStyles.bodySmall.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
