#pragma once

#include "Config.h"
#include "StudySession.h"
#include "FaceRenderer.h"
#include "EarAnimator.h"
#include "SoundPlayer.h"
#include "SerialProtocol.h"

class StudyCoach {
public:
  StudyCoach();

  void begin();
  void loop();

private:
  static const unsigned long kRenderIntervalMs = 200;
  static const unsigned long kWarningBlinkIntervalMs = 200;

  static void handleStudyEvent(void *context, StudyEvent event, StudyState state, int cycle);
  static void handleEarRequest(void *context);

  void onPhaseStarted(StudyState state, int cycle);
  void onWarning();
  void onPaused();
  void onResumed();
  void onStopped();
  void onIdlePerk();
  void updateIndicatorLed();
  void scanI2CBus() const;

  SessionConfig config_;
  StudySession session_;
  FaceRenderer face_;
  EarAnimator ears_;
  SoundPlayer sound_;
  SerialProtocol serial_;
  unsigned long lastRenderMs_;
  bool oledReady_;
};
