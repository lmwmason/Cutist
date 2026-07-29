#include "SerialProtocol.h"
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

SerialProtocol::SerialProtocol(StudySession &session, SessionConfig &config, EarRequestCallback onEarRequest, void *earRequestContext)
  : session_(session),
    config_(config),
    onEarRequest_(onEarRequest),
    earRequestContext_(earRequestContext),
    lineLength_(0),
    lastBroadcastMs_(0) {}

void SerialProtocol::begin() {
  lineLength_ = 0;
  lastBroadcastMs_ = 0;
  printHelp();
}

void SerialProtocol::poll() {
  while (Serial.available() > 0) {
    char incoming = Serial.read();
    if (incoming == '\r') {
      continue;
    }
    if (incoming == '\n') {
      lineBuffer_[lineLength_] = '\0';
      if (lineLength_ > 0) {
        handleLine(lineBuffer_);
      }
      lineLength_ = 0;
      continue;
    }
    if (lineLength_ < kLineBufferSize - 1) {
      lineBuffer_[lineLength_++] = incoming;
    }
  }

  unsigned long now = millis();
  if (now - lastBroadcastMs_ >= kBroadcastIntervalMs) {
    lastBroadcastMs_ = now;
    broadcastStatus();
  }
}

void SerialProtocol::broadcastStatus() const {
  Serial.print(F("STAT,"));
  Serial.print(stateName(session_.state()));
  Serial.print(',');
  Serial.print(session_.cycle());
  Serial.print(',');
  Serial.print(session_.remainingSeconds());
  Serial.print(',');
  Serial.print(session_.phaseTotalSeconds());
  Serial.print(',');
  Serial.print(session_.studiedSeconds());
  Serial.print(',');
  Serial.println(session_.cyclesUntilLongBreak());
}

void SerialProtocol::handleLine(char *line) {
  for (char *p = line; *p; p++) {
    *p = toupper(*p);
  }

  if (strcmp(line, "START") == 0) {
    session_.start();
    printOk("START");
    return;
  }
  if (strcmp(line, "PAUSE") == 0) {
    session_.pause();
    printOk("PAUSE");
    return;
  }
  if (strcmp(line, "RESUME") == 0) {
    session_.resume();
    printOk("RESUME");
    return;
  }
  if (strcmp(line, "STOP") == 0) {
    session_.stop();
    printOk("STOP");
    return;
  }
  if (strcmp(line, "SKIP") == 0) {
    session_.skip();
    printOk("SKIP");
    return;
  }
  if (strcmp(line, "STATUS") == 0) {
    broadcastStatus();
    return;
  }
  if (strcmp(line, "PING") == 0) {
    Serial.println(F("PONG"));
    return;
  }
  if (strcmp(line, "EAR") == 0) {
    if (onEarRequest_ != nullptr) {
      onEarRequest_(earRequestContext_);
    }
    printOk("EAR");
    return;
  }
  if (strcmp(line, "HELP") == 0) {
    printHelp();
    return;
  }
  if (strncmp(line, "SET ", 4) == 0) {
    handleSetCommand(line + 4);
    return;
  }

  printError("UNKNOWN_CMD");
}

void SerialProtocol::handleSetCommand(char *arguments) {
  char *equalsSign = strchr(arguments, '=');
  if (equalsSign == nullptr) {
    printError("BAD_SET");
    return;
  }
  *equalsSign = '\0';
  const char *key = arguments;
  float value = atof(equalsSign + 1);

  if (strcmp(key, "FOCUS_BASE") == 0) {
    config_.focusBaseMinutes = value;
  } else if (strcmp(key, "FOCUS_STEP") == 0) {
    config_.focusStepMinutes = value;
  } else if (strcmp(key, "FOCUS_MAX") == 0) {
    config_.focusMaxMinutes = value;
  } else if (strcmp(key, "BREAK_BASE") == 0) {
    config_.breakBaseMinutes = value;
  } else if (strcmp(key, "BREAK_STEP") == 0) {
    config_.breakStepMinutes = value;
  } else if (strcmp(key, "BREAK_MAX") == 0) {
    config_.breakMaxMinutes = value;
  } else if (strcmp(key, "LONG_BREAK") == 0) {
    config_.longBreakMinutes = value;
  } else if (strcmp(key, "CYCLES") == 0) {
    if (value < 1) {
      printError("BAD_VALUE");
      return;
    }
    config_.cyclesPerLongBreak = (int)value;
  } else if (strcmp(key, "WARN_SEC") == 0) {
    if (value < 0) {
      printError("BAD_VALUE");
      return;
    }
    config_.warningSeconds = (int)value;
  } else if (strcmp(key, "PERK_MIN") == 0) {
    if (value < 0) {
      printError("BAD_VALUE");
      return;
    }
    config_.idlePerkIntervalMinutes = (int)value;
  } else if (strcmp(key, "TIMESCALE") == 0) {
    if (value <= 0) {
      printError("BAD_VALUE");
      return;
    }
    config_.timeScale = value;
  } else {
    printError("BAD_KEY");
    return;
  }

  printOk(key);
}

void SerialProtocol::printOk(const char *command) const {
  Serial.print(F("OK,"));
  Serial.println(command);
}

void SerialProtocol::printError(const char *reason) const {
  Serial.print(F("ERR,"));
  Serial.println(reason);
}

void SerialProtocol::printHelp() const {
  Serial.println(F("START"));
  Serial.println(F("PAUSE"));
  Serial.println(F("RESUME"));
  Serial.println(F("STOP"));
  Serial.println(F("SKIP"));
  Serial.println(F("STATUS"));
  Serial.println(F("PING"));
  Serial.println(F("EAR"));
  Serial.println(F("SET FOCUS_BASE=15"));
  Serial.println(F("SET FOCUS_STEP=5"));
  Serial.println(F("SET FOCUS_MAX=50"));
  Serial.println(F("SET BREAK_BASE=5"));
  Serial.println(F("SET BREAK_STEP=1"));
  Serial.println(F("SET BREAK_MAX=15"));
  Serial.println(F("SET LONG_BREAK=25"));
  Serial.println(F("SET CYCLES=4"));
  Serial.println(F("SET WARN_SEC=60"));
  Serial.println(F("SET PERK_MIN=10"));
  Serial.println(F("SET TIMESCALE=1"));
}

const char *SerialProtocol::stateName(StudyState state) const {
  switch (state) {
    case StudyState::Idle:
      return "IDLE";
    case StudyState::Focus:
      return "FOCUS";
    case StudyState::ShortBreak:
      return "SHORT_BREAK";
    case StudyState::LongBreak:
      return "LONG_BREAK";
    case StudyState::Paused:
      return "PAUSED";
  }
  return "UNKNOWN";
}
