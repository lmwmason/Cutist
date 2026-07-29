#pragma once

#include <Arduino.h>
#include "Config.h"

enum class StudyEvent {
  PhaseStarted,
  Warning,
  Paused,
  Resumed,
  Stopped,
  IdlePerk
};

typedef void (*StudyEventCallback)(void *context, StudyEvent event, StudyState state, int cycle);

class StudySession {
public:
  StudySession(SessionConfig &config, StudyEventCallback callback, void *callbackContext);

  void start();
  void pause();
  void resume();
  void stop();
  void skip();
  void update();

  StudyState state() const;
  int cycle() const;
  unsigned long remainingSeconds() const;
  unsigned long phaseTotalSeconds() const;
  unsigned long studiedSeconds() const;
  int cyclesUntilLongBreak() const;
  bool isWarningActive() const;

private:
  void enterFocus();
  void enterShortBreak();
  void enterLongBreak();
  void enterIdle();

  unsigned long focusDurationMs(int cycle) const;
  unsigned long breakDurationMs(int cycle) const;
  unsigned long longBreakDurationMs() const;

  void notify(StudyEvent event);

  SessionConfig &config_;
  StudyEventCallback callback_;
  void *callbackContext_;

  StudyState state_;
  StudyState stateBeforePause_;
  int cycle_;
  unsigned long phaseStartMs_;
  unsigned long phaseDurationMs_;
  unsigned long pausedRemainingMs_;
  unsigned long studiedMs_;
  unsigned long lastPerkMs_;
  bool warningFired_;
};
