import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/coach_controller.dart';
import '../theme/toss_tokens.dart';
import 'toss_button.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: TossColors.canvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(TossRadius.buttonXLarge)),
    ),
    builder: (context) => const _SettingsSheetBody(),
  );
}

class _SettingsSheetBody extends StatefulWidget {
  const _SettingsSheetBody();

  @override
  State<_SettingsSheetBody> createState() => _SettingsSheetBodyState();
}

class _SettingsSheetBodyState extends State<_SettingsSheetBody> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    final config = context.read<CoachController>().config;
    _fields = {
      'focusBase': TextEditingController(text: config.focusBaseMinutes.toStringAsFixed(0)),
      'focusStep': TextEditingController(text: config.focusStepMinutes.toStringAsFixed(0)),
      'focusMax': TextEditingController(text: config.focusMaxMinutes.toStringAsFixed(0)),
      'breakBase': TextEditingController(text: config.breakBaseMinutes.toStringAsFixed(0)),
      'breakStep': TextEditingController(text: config.breakStepMinutes.toStringAsFixed(0)),
      'breakMax': TextEditingController(text: config.breakMaxMinutes.toStringAsFixed(0)),
      'longBreak': TextEditingController(text: config.longBreakMinutes.toStringAsFixed(0)),
      'cycles': TextEditingController(text: config.cyclesPerLongBreak.toString()),
      'warnSec': TextEditingController(text: config.warningSeconds.toString()),
      'perkMin': TextEditingController(text: config.idlePerkIntervalMinutes.toString()),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _asDouble(String key) => double.tryParse(_fields[key]!.text) ?? 0;
  int _asInt(String key) => int.tryParse(_fields[key]!.text) ?? 0;

  void _apply() {
    final coach = context.read<CoachController>();
    coach.setFocusBase(_asDouble('focusBase'));
    coach.setFocusStep(_asDouble('focusStep'));
    coach.setFocusMax(_asDouble('focusMax'));
    coach.setBreakBase(_asDouble('breakBase'));
    coach.setBreakStep(_asDouble('breakStep'));
    coach.setBreakMax(_asDouble('breakMax'));
    coach.setLongBreak(_asDouble('longBreak'));
    coach.setCyclesPerLongBreak(_asInt('cycles'));
    coach.setWarningSeconds(_asInt('warnSec'));
    coach.setIdlePerkMinutes(_asInt('perkMin'));
    Navigator.of(context).pop();
  }

  Widget _field(String key, String label, {String suffix = 'min'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TossSpacing.lg),
      child: TextField(
        controller: _fields[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: suffix),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        TossSpacing.xl,
        TossSpacing.xl,
        TossSpacing.xl,
        MediaQuery.of(context).viewInsets.bottom + TossSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Settings', style: TossTextStyles.h3),
            const SizedBox(height: TossSpacing.xl),
            _field('focusBase', 'Starting focus length'),
            _field('focusStep', 'Focus increase per cycle'),
            _field('focusMax', 'Focus length cap'),
            _field('breakBase', 'Starting break length'),
            _field('breakStep', 'Break increase per cycle'),
            _field('breakMax', 'Break length cap'),
            _field('longBreak', 'Long break length'),
            _field('cycles', 'Cycles before a long break', suffix: 'cycles'),
            _field('warnSec', 'Warning before focus ends', suffix: 'sec'),
            _field('perkMin', 'Ear wiggle interval during focus'),
            const SizedBox(height: TossSpacing.md),
            TossButton(label: 'Apply', onPressed: _apply),
          ],
        ),
      ),
    );
  }
}
