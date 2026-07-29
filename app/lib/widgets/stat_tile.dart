import 'package:flutter/material.dart';

import '../theme/toss_tokens.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TossSpacing.lg),
      decoration: BoxDecoration(
        color: TossColors.surface,
        borderRadius: BorderRadius.circular(TossRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TossTextStyles.bodySmall),
          const SizedBox(height: TossSpacing.xs),
          Text(value, style: TossTextStyles.h4),
        ],
      ),
    );
  }
}
