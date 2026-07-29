#pragma once

#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "Config.h"

class FaceRenderer {
public:
  FaceRenderer();

  bool begin();
  void render(StudyState state, int cycle, unsigned long remainingSeconds, bool warningActive);

private:
  enum class Expression {
    Sleepy,
    Paused,
    Content,
    Determined,
    Alert,
    Cheerful,
    Radiant
  };

  static const int kLeftEyeX = 40;
  static const int kRightEyeX = 88;
  static const int kEyeY = 30;
  static const int kMouthCenterX = 64;
  static const int kMouthY = 48;

  Expression expressionFor(StudyState state, int cycle, bool warningActive) const;
  const char *stateLabel(StudyState state) const;

  void drawHeader(StudyState state, unsigned long remainingSeconds);
  void drawEyesRound();
  void drawEyesNarrow();
  void drawEyesCaret();
  void drawEyesFlat();
  void drawEyesWide();
  void drawMouthFlat();
  void drawMouthSmallSmile();
  void drawMouthBigSmile();
  void drawMouthAlert();
  void drawPauseGlyph();
  void drawSparkles();
  void drawCurve(int cx, int cy, int width, int depth);

  Adafruit_SSD1306 display_;
};
