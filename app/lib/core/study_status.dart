import 'study_state.dart';

class StudyStatus {
  final StudyState state;
  final int cycle;
  final int remainingSeconds;
  final int phaseTotalSeconds;
  final int studiedSeconds;
  final int cyclesUntilLongBreak;

  const StudyStatus({
    required this.state,
    required this.cycle,
    required this.remainingSeconds,
    required this.phaseTotalSeconds,
    required this.studiedSeconds,
    required this.cyclesUntilLongBreak,
  });

  static const idle = StudyStatus(
    state: StudyState.idle,
    cycle: 0,
    remainingSeconds: 0,
    phaseTotalSeconds: 0,
    studiedSeconds: 0,
    cyclesUntilLongBreak: 0,
  );

  double get progress {
    if (phaseTotalSeconds <= 0) return 0;
    final elapsed = phaseTotalSeconds - remainingSeconds;
    return (elapsed / phaseTotalSeconds).clamp(0.0, 1.0);
  }

  static StudyStatus? parse(String line) {
    final parts = line.split(',');
    if (parts.length != 7 || parts[0] != 'STAT') return null;
    final values = parts.sublist(2).map(int.tryParse).toList();
    if (values.any((value) => value == null)) return null;
    return StudyStatus(
      state: studyStateFromWire(parts[1]),
      cycle: values[0]!,
      remainingSeconds: values[1]!,
      phaseTotalSeconds: values[2]!,
      studiedSeconds: values[3]!,
      cyclesUntilLongBreak: values[4]!,
    );
  }
}
