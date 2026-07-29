import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/coach_controller.dart';
import '../core/study_state.dart';
import '../core/study_status.dart';
import '../theme/toss_tokens.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/cycle_dots.dart';
import '../widgets/pulsing_ring.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/stat_tile.dart';
import '../widgets/state_badge.dart';
import '../widgets/toss_button.dart';
import 'connect_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static bool _isActivePhase(StudyState state) {
    return state == StudyState.focus ||
        state == StudyState.shortBreak ||
        state == StudyState.longBreak;
  }

  Future<void> _disconnect(BuildContext context) async {
    final coach = context.read<CoachController>();
    await coach.disconnect();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ConnectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CoachController>(
        builder: (context, coach, _) {
          final status = coach.status;
          final accent = accentForState(status.state);
          final isActive = _isActivePhase(status.state);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.6],
                colors: [accent.withValues(alpha: 0.10), TossColors.canvas],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    showWarning: !coach.oledReady || !coach.deviceResponding,
                    warningMessage: !coach.deviceResponding
                        ? 'Device is not responding'
                        : 'Display not detected',
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.tune, color: TossColors.body),
                        onPressed: () => showSettingsSheet(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.link_off, color: TossColors.body),
                        onPressed: () => _disconnect(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: TossSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PulsingRing(
                              isActive: status.state == StudyState.focus,
                              child: CountdownRing(status: status),
                            ),
                            const SizedBox(height: TossSpacing.xl),
                            CycleDots(
                              totalCycles: coach.config.cyclesPerLongBreak,
                              cyclesUntilLongBreak: status.cyclesUntilLongBreak,
                              accent: accent,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: isActive
                                  ? const SizedBox(
                                      height: TossSpacing.xxl,
                                      key: ValueKey('spacer'),
                                    )
                                  : Padding(
                                      key: const ValueKey('stats'),
                                      padding: const EdgeInsets.only(top: TossSpacing.xxl),
                                      child: _StatsRow(status: status),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TossSpacing.xl,
                      0,
                      TossSpacing.xl,
                      TossSpacing.xl,
                    ),
                    child: _ControlButtons(status: status, coach: coach),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final StudyStatus status;

  const _StatsRow({required this.status});

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            label: 'Studied today',
            value: _formatDuration(status.studiedSeconds),
          ),
        ),
        const SizedBox(width: TossSpacing.lg),
        Expanded(
          child: StatTile(label: 'Current cycle', value: '${status.cycle + 1}'),
        ),
      ],
    );
  }
}

class _ControlButtons extends StatelessWidget {
  final StudyStatus status;
  final CoachController coach;

  const _ControlButtons({required this.status, required this.coach});

  @override
  Widget build(BuildContext context) {
    switch (status.state) {
      case StudyState.idle:
        return TossButton(label: 'Start studying', onPressed: coach.start);
      case StudyState.paused:
        return Column(
          children: [
            TossButton(label: 'Resume', onPressed: coach.resume),
            const SizedBox(height: TossSpacing.md),
            TossButton(
              label: 'End session',
              variant: TossButtonVariant.weak,
              accent: TossColors.danger,
              onPressed: coach.stop,
            ),
          ],
        );
      case StudyState.focus:
      case StudyState.shortBreak:
      case StudyState.longBreak:
        return Column(
          children: [
            TossButton(label: 'Pause', onPressed: coach.pause),
            const SizedBox(height: TossSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TossButton(
                    label: 'Skip',
                    variant: TossButtonVariant.weak,
                    onPressed: coach.skip,
                  ),
                ),
                const SizedBox(width: TossSpacing.md),
                Expanded(
                  child: TossButton(
                    label: 'End session',
                    variant: TossButtonVariant.weak,
                    accent: TossColors.danger,
                    onPressed: coach.stop,
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}
