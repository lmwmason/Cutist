#pragma once

#define PIN_EAR_LEFT 9
#define PIN_EAR_RIGHT 10
#define PIN_PIEZO A1
#define PIN_LED 13

enum class StudyState {
  Idle,
  Focus,
  ShortBreak,
  LongBreak,
  Paused
};

struct SessionConfig {
  float focusBaseMinutes = 15.0f;
  float focusStepMinutes = 5.0f;
  float focusMaxMinutes = 50.0f;
  float breakBaseMinutes = 5.0f;
  float breakStepMinutes = 1.0f;
  float breakMaxMinutes = 15.0f;
  float longBreakMinutes = 25.0f;
  int cyclesPerLongBreak = 4;
  int warningSeconds = 60;
  int idlePerkIntervalMinutes = 10;
  float timeScale = 1.0f;
};
