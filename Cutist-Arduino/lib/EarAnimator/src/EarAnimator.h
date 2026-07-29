#pragma once

#include <Servo.h>

class EarAnimator {
public:
  void begin();
  void rest();
  void greet();
  void perk();
  void celebrate();
  void droop();

private:
  static const int kRestAngle = 90;

  void moveTo(int leftAngle, int rightAngle, uint16_t settleMs);

  Servo leftEar_;
  Servo rightEar_;
};
