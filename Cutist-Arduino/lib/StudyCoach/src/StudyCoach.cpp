#include "StudyCoach.h"
#include <Wire.h>

StudyCoach::StudyCoach()
  : session_(config_, &StudyCoach::handleStudyEvent, this),
    serial_(session_, config_, &StudyCoach::handleEarRequest, this),
    lastRenderMs_(0),
    oledReady_(false) {}

void StudyCoach::begin() {
  Serial.begin(9600);
  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_LED, LOW);
  oledReady_ = face_.begin();
  Serial.println(oledReady_ ? F("OLED,INIT,OK") : F("OLED,INIT,FAIL"));
  if (!oledReady_) {
    scanI2CBus();
  }
  ears_.begin();
  sound_.begin();
  serial_.begin();
}

void StudyCoach::loop() {
  serial_.poll();
  session_.update();
  updateIndicatorLed();

  if (!oledReady_) {
    return;
  }

  unsigned long now = millis();
  if (now - lastRenderMs_ >= kRenderIntervalMs) {
    lastRenderMs_ = now;
    face_.render(session_.state(), session_.cycle(), session_.remainingSeconds(), session_.isWarningActive());
  }
}

void StudyCoach::handleStudyEvent(void *context, StudyEvent event, StudyState state, int cycle) {
  StudyCoach *self = static_cast<StudyCoach *>(context);
  switch (event) {
    case StudyEvent::PhaseStarted:
      self->onPhaseStarted(state, cycle);
      break;
    case StudyEvent::Warning:
      self->onWarning();
      break;
    case StudyEvent::Paused:
      self->onPaused();
      break;
    case StudyEvent::Resumed:
      self->onResumed();
      break;
    case StudyEvent::Stopped:
      self->onStopped();
      break;
    case StudyEvent::IdlePerk:
      self->onIdlePerk();
      break;
  }
}

void StudyCoach::handleEarRequest(void *context) {
  StudyCoach *self = static_cast<StudyCoach *>(context);
  self->ears_.perk();
}

void StudyCoach::onPhaseStarted(StudyState state, int cycle) {
  switch (state) {
    case StudyState::Focus:
      if (cycle == 0) {
        sound_.playSessionStart();
        ears_.greet();
      } else {
        sound_.playFocusBegin();
        ears_.perk();
      }
      break;
    case StudyState::ShortBreak:
      sound_.playBreakBegin();
      ears_.celebrate();
      break;
    case StudyState::LongBreak:
      sound_.playLongBreakBegin();
      ears_.celebrate();
      break;
    default:
      break;
  }
}

void StudyCoach::onWarning() {
  sound_.playWarning();
  ears_.perk();
}

void StudyCoach::onPaused() {
  sound_.playPause();
}

void StudyCoach::onResumed() {
  sound_.playResume();
}

void StudyCoach::onStopped() {
  sound_.playStop();
  ears_.droop();
}

void StudyCoach::onIdlePerk() {
  ears_.perk();
}

void StudyCoach::scanI2CBus() const {
  Serial.println(F("I2C,SCAN,START"));
  for (uint8_t address = 1; address < 127; address++) {
    Wire.beginTransmission(address);
    if (Wire.endTransmission() == 0) {
      Serial.print(F("I2C,FOUND,0x"));
      Serial.println(address, HEX);
    }
  }
  Serial.println(F("I2C,SCAN,END"));
}

void StudyCoach::updateIndicatorLed() {
  if (session_.state() != StudyState::Focus) {
    digitalWrite(PIN_LED, LOW);
    return;
  }
  if (session_.isWarningActive()) {
    digitalWrite(PIN_LED, (millis() / kWarningBlinkIntervalMs) % 2 == 0 ? HIGH : LOW);
  } else {
    digitalWrite(PIN_LED, HIGH);
  }
}
