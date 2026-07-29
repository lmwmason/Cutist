#include "FaceRenderer.h"
#include <Wire.h>

FaceRenderer::FaceRenderer() : display_(128, 64, &Wire, -1) {}

bool FaceRenderer::begin() {
  bool ok = display_.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display_.setTextColor(SSD1306_WHITE);
  display_.setTextSize(1);
  display_.clearDisplay();
  display_.display();
  return ok;
}

void FaceRenderer::render(StudyState state, int cycle, unsigned long remainingSeconds, bool warningActive) {
  display_.clearDisplay();
  drawHeader(state, remainingSeconds);

  switch (expressionFor(state, cycle, warningActive)) {
    case Expression::Sleepy:
      drawEyesFlat();
      drawMouthFlat();
      break;
    case Expression::Paused:
      drawEyesFlat();
      drawPauseGlyph();
      break;
    case Expression::Content:
      drawEyesRound();
      drawMouthSmallSmile();
      break;
    case Expression::Determined:
      drawEyesNarrow();
      drawMouthFlat();
      break;
    case Expression::Alert:
      drawEyesWide();
      drawMouthAlert();
      break;
    case Expression::Cheerful:
      drawEyesCaret();
      drawMouthBigSmile();
      break;
    case Expression::Radiant:
      drawEyesCaret();
      drawMouthBigSmile();
      drawSparkles();
      break;
  }

  display_.display();
}

FaceRenderer::Expression FaceRenderer::expressionFor(StudyState state, int cycle, bool warningActive) const {
  switch (state) {
    case StudyState::Idle:
      return Expression::Sleepy;
    case StudyState::Paused:
      return Expression::Paused;
    case StudyState::Focus:
      if (warningActive) {
        return Expression::Alert;
      }
      return cycle < 2 ? Expression::Content : Expression::Determined;
    case StudyState::ShortBreak:
      return Expression::Cheerful;
    case StudyState::LongBreak:
      return Expression::Radiant;
  }
  return Expression::Sleepy;
}

const char *FaceRenderer::stateLabel(StudyState state) const {
  switch (state) {
    case StudyState::Idle:
      return "IDLE";
    case StudyState::Focus:
      return "FOCUS";
    case StudyState::ShortBreak:
      return "BREAK";
    case StudyState::LongBreak:
      return "LONG BREAK";
    case StudyState::Paused:
      return "PAUSED";
  }
  return "";
}

void FaceRenderer::drawHeader(StudyState state, unsigned long remainingSeconds) {
  display_.setCursor(0, 0);
  display_.print(stateLabel(state));

  unsigned long minutes = remainingSeconds / 60;
  unsigned long seconds = remainingSeconds % 60;
  char buffer[6];
  buffer[0] = '0' + (minutes / 10) % 10;
  buffer[1] = '0' + minutes % 10;
  buffer[2] = ':';
  buffer[3] = '0' + (seconds / 10) % 10;
  buffer[4] = '0' + seconds % 10;
  buffer[5] = '\0';

  display_.setCursor(128 - 30, 0);
  display_.print(buffer);
}

void FaceRenderer::drawEyesRound() {
  display_.fillCircle(kLeftEyeX, kEyeY, 5, SSD1306_WHITE);
  display_.fillCircle(kRightEyeX, kEyeY, 5, SSD1306_WHITE);
}

void FaceRenderer::drawEyesNarrow() {
  display_.fillRoundRect(kLeftEyeX - 7, kEyeY - 2, 14, 4, 2, SSD1306_WHITE);
  display_.fillRoundRect(kRightEyeX - 7, kEyeY - 2, 14, 4, 2, SSD1306_WHITE);
}

void FaceRenderer::drawEyesCaret() {
  display_.drawLine(kLeftEyeX - 6, kEyeY + 3, kLeftEyeX, kEyeY - 3, SSD1306_WHITE);
  display_.drawLine(kLeftEyeX, kEyeY - 3, kLeftEyeX + 6, kEyeY + 3, SSD1306_WHITE);
  display_.drawLine(kRightEyeX - 6, kEyeY + 3, kRightEyeX, kEyeY - 3, SSD1306_WHITE);
  display_.drawLine(kRightEyeX, kEyeY - 3, kRightEyeX + 6, kEyeY + 3, SSD1306_WHITE);
}

void FaceRenderer::drawEyesFlat() {
  display_.drawFastHLine(kLeftEyeX - 6, kEyeY, 12, SSD1306_WHITE);
  display_.drawFastHLine(kRightEyeX - 6, kEyeY, 12, SSD1306_WHITE);
}

void FaceRenderer::drawEyesWide() {
  display_.fillCircle(kLeftEyeX, kEyeY, 7, SSD1306_WHITE);
  display_.fillCircle(kRightEyeX, kEyeY, 7, SSD1306_WHITE);
  display_.fillCircle(kLeftEyeX, kEyeY, 2, SSD1306_BLACK);
  display_.fillCircle(kRightEyeX, kEyeY, 2, SSD1306_BLACK);
}

void FaceRenderer::drawMouthFlat() {
  display_.drawFastHLine(kMouthCenterX - 14, kMouthY, 28, SSD1306_WHITE);
}

void FaceRenderer::drawMouthSmallSmile() {
  drawCurve(kMouthCenterX, kMouthY - 2, 24, 6);
}

void FaceRenderer::drawMouthBigSmile() {
  drawCurve(kMouthCenterX, kMouthY - 2, 36, 10);
}

void FaceRenderer::drawMouthAlert() {
  display_.drawCircle(kMouthCenterX, kMouthY, 4, SSD1306_WHITE);
}

void FaceRenderer::drawPauseGlyph() {
  display_.fillRect(kMouthCenterX - 8, kMouthY - 6, 4, 12, SSD1306_WHITE);
  display_.fillRect(kMouthCenterX + 4, kMouthY - 6, 4, 12, SSD1306_WHITE);
}

void FaceRenderer::drawSparkles() {
  display_.drawPixel(kLeftEyeX - 14, kEyeY - 10, SSD1306_WHITE);
  display_.drawPixel(kRightEyeX + 14, kEyeY - 10, SSD1306_WHITE);
  display_.drawPixel(kLeftEyeX - 10, kEyeY - 16, SSD1306_WHITE);
  display_.drawPixel(kRightEyeX + 10, kEyeY - 16, SSD1306_WHITE);
}

void FaceRenderer::drawCurve(int cx, int cy, int width, int depth) {
  int halfWidth = width / 2;
  for (int x = -halfWidth; x <= halfWidth; x++) {
    int y = cy + depth - (depth * x * x) / (halfWidth * halfWidth);
    display_.drawPixel(cx + x, y, SSD1306_WHITE);
  }
}
