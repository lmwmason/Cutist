#pragma once

#include <Arduino.h>

class SoundPlayer {
public:
  void begin();
  void playSessionStart() const;
  void playFocusBegin() const;
  void playBreakBegin() const;
  void playLongBreakBegin() const;
  void playWarning() const;
  void playPause() const;
  void playResume() const;
  void playStop() const;

private:
  void playNote(unsigned int frequency, unsigned int durationMs) const;
};
