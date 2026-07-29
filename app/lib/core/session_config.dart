class SessionConfig {
  final double focusBaseMinutes;
  final double focusStepMinutes;
  final double focusMaxMinutes;
  final double breakBaseMinutes;
  final double breakStepMinutes;
  final double breakMaxMinutes;
  final double longBreakMinutes;
  final int cyclesPerLongBreak;
  final int warningSeconds;
  final int idlePerkIntervalMinutes;

  const SessionConfig({
    this.focusBaseMinutes = 15,
    this.focusStepMinutes = 5,
    this.focusMaxMinutes = 50,
    this.breakBaseMinutes = 5,
    this.breakStepMinutes = 1,
    this.breakMaxMinutes = 15,
    this.longBreakMinutes = 25,
    this.cyclesPerLongBreak = 4,
    this.warningSeconds = 60,
    this.idlePerkIntervalMinutes = 10,
  });

  SessionConfig copyWith({
    double? focusBaseMinutes,
    double? focusStepMinutes,
    double? focusMaxMinutes,
    double? breakBaseMinutes,
    double? breakStepMinutes,
    double? breakMaxMinutes,
    double? longBreakMinutes,
    int? cyclesPerLongBreak,
    int? warningSeconds,
    int? idlePerkIntervalMinutes,
  }) {
    return SessionConfig(
      focusBaseMinutes: focusBaseMinutes ?? this.focusBaseMinutes,
      focusStepMinutes: focusStepMinutes ?? this.focusStepMinutes,
      focusMaxMinutes: focusMaxMinutes ?? this.focusMaxMinutes,
      breakBaseMinutes: breakBaseMinutes ?? this.breakBaseMinutes,
      breakStepMinutes: breakStepMinutes ?? this.breakStepMinutes,
      breakMaxMinutes: breakMaxMinutes ?? this.breakMaxMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      cyclesPerLongBreak: cyclesPerLongBreak ?? this.cyclesPerLongBreak,
      warningSeconds: warningSeconds ?? this.warningSeconds,
      idlePerkIntervalMinutes:
          idlePerkIntervalMinutes ?? this.idlePerkIntervalMinutes,
    );
  }
}
