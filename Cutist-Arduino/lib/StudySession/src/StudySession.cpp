#include "StudySession.h"

StudySession::StudySession(SessionConfig &config, StudyEventCallback callback, void *callbackContext)
  : config_(config),
    callback_(callback),
    callbackContext_(callbackContext),
    state_(StudyState::Idle),
    stateBeforePause_(StudyState::Idle),
    cycle_(0),
    phaseStartMs_(0),
    phaseDurationMs_(0),
    pausedRemainingMs_(0),
    studiedMs_(0),
    lastPerkMs_(0),
    warningFired_(false) {}

void StudySession::start() {
  cycle_ = 0;
  studiedMs_ = 0;
  enterFocus();
}

void StudySession::pause() {
  if (state_ != StudyState::Focus && state_ != StudyState::ShortBreak && state_ != StudyState::LongBreak) {
    return;
  }
  unsigned long elapsed = millis() - phaseStartMs_;
  pausedRemainingMs_ = elapsed >= phaseDurationMs_ ? 0 : phaseDurationMs_ - elapsed;
  stateBeforePause_ = state_;
  state_ = StudyState::Paused;
  notify(StudyEvent::Paused);
}

void StudySession::resume() {
  if (state_ != StudyState::Paused) {
    return;
  }
  state_ = stateBeforePause_;
  phaseStartMs_ = millis();
  phaseDurationMs_ = pausedRemainingMs_;
  notify(StudyEvent::Resumed);
}

void StudySession::stop() {
  enterIdle();
  notify(StudyEvent::Stopped);
}

void StudySession::skip() {
  switch (state_) {
    case StudyState::Focus:
      studiedMs_ += millis() - phaseStartMs_;
      cycle_++;
      if (cycle_ % config_.cyclesPerLongBreak == 0) {
        enterLongBreak();
      } else {
        enterShortBreak();
      }
      break;
    case StudyState::ShortBreak:
      enterFocus();
      break;
    case StudyState::LongBreak:
      cycle_ = 0;
      enterFocus();
      break;
    default:
      break;
  }
}

void StudySession::update() {
  if (state_ == StudyState::Idle || state_ == StudyState::Paused) {
    return;
  }

  unsigned long now = millis();
  unsigned long elapsed = now - phaseStartMs_;

  if (state_ == StudyState::Focus) {
    unsigned long warningWindowMs = (unsigned long)config_.warningSeconds * 1000UL;
    if (!warningFired_ && warningWindowMs < phaseDurationMs_ && elapsed >= phaseDurationMs_ - warningWindowMs) {
      warningFired_ = true;
      notify(StudyEvent::Warning);
    }

    unsigned long perkIntervalMs = (unsigned long)config_.idlePerkIntervalMinutes * 60000UL;
    if (perkIntervalMs > 0 && now - lastPerkMs_ >= perkIntervalMs) {
      lastPerkMs_ = now;
      notify(StudyEvent::IdlePerk);
    }
  }

  if (elapsed < phaseDurationMs_) {
    return;
  }

  if (state_ == StudyState::Focus) {
    studiedMs_ += phaseDurationMs_;
    cycle_++;
    if (cycle_ % config_.cyclesPerLongBreak == 0) {
      enterLongBreak();
    } else {
      enterShortBreak();
    }
  } else if (state_ == StudyState::ShortBreak) {
    enterFocus();
  } else if (state_ == StudyState::LongBreak) {
    cycle_ = 0;
    enterFocus();
  }
}

StudyState StudySession::state() const {
  return state_;
}

int StudySession::cycle() const {
  return cycle_;
}

unsigned long StudySession::remainingSeconds() const {
  if (state_ == StudyState::Idle) {
    return 0;
  }
  if (state_ == StudyState::Paused) {
    return pausedRemainingMs_ / 1000UL;
  }
  unsigned long elapsed = millis() - phaseStartMs_;
  if (elapsed >= phaseDurationMs_) {
    return 0;
  }
  return (phaseDurationMs_ - elapsed) / 1000UL;
}

unsigned long StudySession::phaseTotalSeconds() const {
  return phaseDurationMs_ / 1000UL;
}

unsigned long StudySession::studiedSeconds() const {
  unsigned long total = studiedMs_;
  if (state_ == StudyState::Focus) {
    total += millis() - phaseStartMs_;
  }
  return total / 1000UL;
}

int StudySession::cyclesUntilLongBreak() const {
  int remainder = cycle_ % config_.cyclesPerLongBreak;
  return config_.cyclesPerLongBreak - remainder;
}

bool StudySession::isWarningActive() const {
  return state_ == StudyState::Focus && warningFired_;
}

void StudySession::enterFocus() {
  state_ = StudyState::Focus;
  phaseStartMs_ = millis();
  phaseDurationMs_ = focusDurationMs(cycle_);
  lastPerkMs_ = phaseStartMs_;
  warningFired_ = false;
  notify(StudyEvent::PhaseStarted);
}

void StudySession::enterShortBreak() {
  state_ = StudyState::ShortBreak;
  phaseStartMs_ = millis();
  phaseDurationMs_ = breakDurationMs(cycle_);
  warningFired_ = false;
  notify(StudyEvent::PhaseStarted);
}

void StudySession::enterLongBreak() {
  state_ = StudyState::LongBreak;
  phaseStartMs_ = millis();
  phaseDurationMs_ = longBreakDurationMs();
  warningFired_ = false;
  notify(StudyEvent::PhaseStarted);
}

void StudySession::enterIdle() {
  state_ = StudyState::Idle;
  cycle_ = 0;
  studiedMs_ = 0;
  warningFired_ = false;
  phaseDurationMs_ = 0;
  phaseStartMs_ = millis();
}

unsigned long StudySession::focusDurationMs(int cycle) const {
  float minutes = config_.focusBaseMinutes + config_.focusStepMinutes * cycle;
  if (minutes > config_.focusMaxMinutes) {
    minutes = config_.focusMaxMinutes;
  }
  return (unsigned long)(minutes * 60000.0f / config_.timeScale);
}

unsigned long StudySession::breakDurationMs(int cycle) const {
  float minutes = config_.breakBaseMinutes + config_.breakStepMinutes * cycle;
  if (minutes > config_.breakMaxMinutes) {
    minutes = config_.breakMaxMinutes;
  }
  return (unsigned long)(minutes * 60000.0f / config_.timeScale);
}

unsigned long StudySession::longBreakDurationMs() const {
  return (unsigned long)(config_.longBreakMinutes * 60000.0f / config_.timeScale);
}

void StudySession::notify(StudyEvent event) {
  callback_(callbackContext_, event, state_, cycle_);
}
