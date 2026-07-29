#include "SoundPlayer.h"
#include "Config.h"

void SoundPlayer::begin() {
  pinMode(PIN_PIEZO, OUTPUT);
}

void SoundPlayer::playSessionStart() const {
  playNote(880, 90);
  playNote(1175, 90);
  playNote(1568, 140);
}

void SoundPlayer::playFocusBegin() const {
  playNote(988, 80);
  playNote(1319, 120);
}

void SoundPlayer::playBreakBegin() const {
  playNote(1319, 80);
  playNote(988, 80);
  playNote(784, 140);
}

void SoundPlayer::playLongBreakBegin() const {
  playNote(784, 100);
  playNote(988, 100);
  playNote(1175, 100);
  playNote(1568, 200);
}

void SoundPlayer::playWarning() const {
  playNote(1568, 60);
  delay(40);
  playNote(1568, 60);
}

void SoundPlayer::playPause() const {
  playNote(659, 100);
}

void SoundPlayer::playResume() const {
  playNote(880, 100);
}

void SoundPlayer::playStop() const {
  playNote(784, 100);
  playNote(587, 160);
}

void SoundPlayer::playNote(unsigned int frequency, unsigned int durationMs) const {
  tone(PIN_PIEZO, frequency, durationMs);
  delay(durationMs + 20);
}
