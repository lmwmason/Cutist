import 'package:flutter/material.dart';

import '../core/study_state.dart';
import '../core/study_status.dart';
import '../theme/toss_tokens.dart';
import 'state_badge.dart';

class CountdownRing extends StatelessWidget {
  final StudyStatus status;

  const CountdownRing({super.key, required this.status});

  String get _timeLabel {
    final minutes = status.remainingSeconds ~/ 60;
    final seconds = status.remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentForState(status.state);
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: status.state == StudyState.idle ? 0 : status.progress,
              strokeWidth: 12,
              backgroundColor: TossColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timeLabel,
                style: TossTextStyles.h1.copyWith(fontSize: 48, height: 1.1),
              ),
              const SizedBox(height: TossSpacing.lg),
              StateBadge(state: status.state),
            ],
          ),
        ],
      ),
    );
  }
}
