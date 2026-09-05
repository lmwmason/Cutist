# Cutist

![C++](https://img.shields.io/badge/C++-00599C?style=flat&logo=cplusplus&logoColor=white)
![Arduino](https://img.shields.io/badge/Arduino-00979D?style=flat&logo=arduino&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-Apache%202.0-blue)

**Cutist: a variable-interval Pomodoro timer that grows your focus blocks as your session goes on, instead of locking you into a fixed 25/5.**

Most Pomodoro devices and apps force a preset that can't change once a session starts — 25/5,
or a switchable-but-fixed 50/10. Cutist runs a rule-based (no AI) adaptive schedule instead: focus
duration increases progressively with the number of completed cycles since the session began, so
the timer adapts to how deep you already are into your work. The device itself is an Arduino Nano
build with an OLED display and servo-driven ears for feedback, paired with a Flutter companion app
over Bluetooth. Built for the 2026 IEEE SSCS Arduino Contest.

## Repository layout

```
Cutist/
├── Cutist-Arduino/    Firmware (C++): adaptive interval logic, OLED UI, servo/buzzer/button drivers
├── app/               Flutter companion app source
├── app-release/       Companion app build artifacts
├── modeling/          3D-printable enclosure models
└── LICENSE
```

## Hardware

| Component | Role |
| --- | --- |
| Arduino Nano | Main controller |
| SSD1306 OLED | Timer state display |
| SG90 servo x2 | Ear motion (D9, D10) |
| Piezo buzzer | Alerts, with an in-line switch for silent mode |
| Potentiometer | Volume control (A7) |
| Push button x3 | Start/pause, reset, mode select |
| Bluetooth module | Link to the companion app |

## Getting started

### Firmware

```bash
# Open in Arduino IDE
Cutist-Arduino/Cutist-Arduino.ino

# Board: Arduino Nano
# Wire per the pin table above, then Upload
```

### App

```bash
cd app
flutter pub get
flutter run
# Pair with the device over Bluetooth from the app
```

### Enclosure

Print the models in `modeling/` and assemble around the Nano + servo/OLED stack.

## License

See [LICENSE](LICENSE).
