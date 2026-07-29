import 'package:flutter/material.dart';

import '../theme/toss_tokens.dart';

class AppTopBar extends StatelessWidget {
  final List<Widget> actions;
  final bool showWarning;
  final String warningMessage;

  const AppTopBar({
    super.key,
    this.actions = const [],
    this.showWarning = false,
    this.warningMessage = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TossSpacing.xl,
        TossSpacing.md,
        TossSpacing.lg,
        TossSpacing.md,
      ),
      child: Row(
        children: [
          Image.asset('logo/cutist-logo.png', height: 72),
          if (showWarning) ...[
            const SizedBox(width: TossSpacing.sm),
            Tooltip(
              message: warningMessage,
              child: const Icon(
                Icons.warning_amber_rounded,
                color: TossColors.danger,
                size: 18,
              ),
            ),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TossSpacing.md,
              vertical: TossSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: TossColors.surface,
              borderRadius: BorderRadius.circular(TossRadius.buttonSmall),
              border: Border.all(color: TossColors.border),
            ),
            child: Image.asset('logo/sscs_ac_logo.png', height: 30),
          ),
          ...actions,
        ],
      ),
    );
  }
}
