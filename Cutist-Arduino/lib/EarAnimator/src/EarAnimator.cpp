#include "EarAnimator.h"
#include <Arduino.h>
#include "Config.h"

void EarAnimator::begin() {
  leftEar_.attach(PIN_EAR_LEFT);
  rightEar_.attach(PIN_EAR_RIGHT);
  rest();
}

void EarAnimator::rest() {
  moveTo(kRestAngle, kRestAngle, 150);
}

void EarAnimator::greet() {
  moveTo(60, 120, 120);
  moveTo(120, 60, 120);
  moveTo(kRestAngle, kRestAngle, 150);
}

void EarAnimator::perk() {
  moveTo(50, 50, 100);
  moveTo(kRestAngle, kRestAngle, 150);
}

void EarAnimator::celebrate() {
  for (int i = 0; i < 3; i++) {
    moveTo(50, 130, 100);
    moveTo(130, 50, 100);
  }
  moveTo(kRestAngle, kRestAngle, 150);
}

void EarAnimator::droop() {
  moveTo(150, 150, 300);
  delay(300);
  moveTo(kRestAngle, kRestAngle, 300);
}

void EarAnimator::moveTo(int leftAngle, int rightAngle, uint16_t settleMs) {
  leftEar_.write(leftAngle);
  rightEar_.write(rightAngle);
  delay(settleMs);
}
