#include <Arduino.h>
#include "StudyCoach.h"

StudyCoach coach;

void setup() {
  coach.begin();
}

void loop() {
  coach.loop();
}
