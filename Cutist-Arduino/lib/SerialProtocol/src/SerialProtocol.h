#pragma once

#include <Arduino.h>
#include "Config.h"
#include "StudySession.h"

typedef void (*EarRequestCallback)(void *context);

class SerialProtocol {
public:
  SerialProtocol(StudySession &session, SessionConfig &config, EarRequestCallback onEarRequest, void *earRequestContext);

  void begin();
  void poll();
  void broadcastStatus() const;

private:
  static const uint8_t kLineBufferSize = 20;
  static const unsigned long kBroadcastIntervalMs = 1000;

  void handleLine(char *line);
  void handleSetCommand(char *arguments);
  void printOk(const char *command) const;
  void printError(const char *reason) const;
  void printHelp() const;
  const char *stateName(StudyState state) const;

  StudySession &session_;
  SessionConfig &config_;
  EarRequestCallback onEarRequest_;
  void *earRequestContext_;
  char lineBuffer_[kLineBufferSize];
  uint8_t lineLength_;
  unsigned long lastBroadcastMs_;
};
