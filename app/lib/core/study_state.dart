enum StudyState { idle, focus, shortBreak, longBreak, paused }

StudyState studyStateFromWire(String raw) {
  switch (raw) {
    case 'FOCUS':
      return StudyState.focus;
    case 'SHORT_BREAK':
      return StudyState.shortBreak;
    case 'LONG_BREAK':
      return StudyState.longBreak;
    case 'PAUSED':
      return StudyState.paused;
    case 'IDLE':
    default:
      return StudyState.idle;
  }
}

extension StudyStateLabel on StudyState {
  String get label {
    switch (this) {
      case StudyState.idle:
        return 'Ready';
      case StudyState.focus:
        return 'Focus';
      case StudyState.shortBreak:
        return 'Break';
      case StudyState.longBreak:
        return 'Long Break';
      case StudyState.paused:
        return 'Paused';
    }
  }
}
