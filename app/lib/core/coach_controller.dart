import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'device_transport.dart';
import 'session_config.dart';
import 'study_status.dart';
import 'transport_factory.dart';

class CoachController extends ChangeNotifier {
  static const Duration _handshakeTimeout = Duration(seconds: 4);
  static const Duration _healthCheckInterval = Duration(seconds: 3);
  static const Duration _healthTimeout = Duration(seconds: 3);

  final List<DeviceTransport> transports;
  final Random _random = Random();

  DeviceTransport? _activeTransport;
  StreamSubscription<String>? _lineSubscription;
  Timer? _earTimer;
  Timer? _healthTimer;
  DateTime? _lastMessageAt;

  bool connecting = false;
  bool connected = false;
  bool deviceResponding = false;
  String? lastError;
  List<TransportDevice> devices = const [];
  StudyStatus status = StudyStatus.idle;
  SessionConfig config = const SessionConfig();
  bool oledReady = true;

  CoachController({List<DeviceTransport>? transports})
      : transports = transports ?? createTransports();

  Future<void> refreshDevices() async {
    final results = <TransportDevice>[];
    for (final transport in transports) {
      results.addAll(await transport.listDevices());
    }
    devices = results;
    notifyListeners();
  }

  Future<void> connect(TransportDevice device) async {
    connecting = true;
    lastError = null;
    deviceResponding = false;
    notifyListeners();
    final transport = device.owner;
    try {
      await transport.connect(device);
      final handshake = Completer<void>();
      _lineSubscription = transport.lines.listen((line) {
        _lastMessageAt = DateTime.now();
        if (!deviceResponding) {
          deviceResponding = true;
          notifyListeners();
        }
        if (!handshake.isCompleted) handshake.complete();
        _handleLine(line);
      });
      transport.send('PING');
      await handshake.future.timeout(_handshakeTimeout);
      _activeTransport = transport;
      connected = true;
      _startHealthWatchdog();
      _scheduleEarWiggle();
    } on TimeoutException {
      await _teardownFailedConnection(transport);
      lastError = 'Device is not responding. Check the cable or pairing and try again.';
    } catch (error) {
      await _teardownFailedConnection(transport);
      lastError = error.toString();
    } finally {
      connecting = false;
      notifyListeners();
    }
  }

  Future<void> _teardownFailedConnection(DeviceTransport transport) async {
    await _lineSubscription?.cancel();
    _lineSubscription = null;
    await transport.disconnect();
    _activeTransport = null;
    connected = false;
    deviceResponding = false;
  }

  void _startHealthWatchdog() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(_healthCheckInterval, (_) {
      final last = _lastMessageAt;
      final stillResponding = last != null && DateTime.now().difference(last) < _healthTimeout;
      if (stillResponding != deviceResponding) {
        deviceResponding = stillResponding;
        notifyListeners();
      }
    });
  }

  Future<void> disconnect() async {
    _earTimer?.cancel();
    _earTimer = null;
    _healthTimer?.cancel();
    _healthTimer = null;
    await _lineSubscription?.cancel();
    _lineSubscription = null;
    await _activeTransport?.disconnect();
    _activeTransport = null;
    connected = false;
    deviceResponding = false;
    status = StudyStatus.idle;
    notifyListeners();
  }

  void _send(String line) => _activeTransport?.send(line);

  void start() => _send('START');
  void pause() => _send('PAUSE');
  void resume() => _send('RESUME');
  void stop() => _send('STOP');
  void skip() => _send('SKIP');

  void setFocusBase(double minutes) {
    _send('SET FOCUS_BASE=$minutes');
    config = config.copyWith(focusBaseMinutes: minutes);
    notifyListeners();
  }

  void setFocusStep(double minutes) {
    _send('SET FOCUS_STEP=$minutes');
    config = config.copyWith(focusStepMinutes: minutes);
    notifyListeners();
  }

  void setFocusMax(double minutes) {
    _send('SET FOCUS_MAX=$minutes');
    config = config.copyWith(focusMaxMinutes: minutes);
    notifyListeners();
  }

  void setBreakBase(double minutes) {
    _send('SET BREAK_BASE=$minutes');
    config = config.copyWith(breakBaseMinutes: minutes);
    notifyListeners();
  }

  void setBreakStep(double minutes) {
    _send('SET BREAK_STEP=$minutes');
    config = config.copyWith(breakStepMinutes: minutes);
    notifyListeners();
  }

  void setBreakMax(double minutes) {
    _send('SET BREAK_MAX=$minutes');
    config = config.copyWith(breakMaxMinutes: minutes);
    notifyListeners();
  }

  void setLongBreak(double minutes) {
    _send('SET LONG_BREAK=$minutes');
    config = config.copyWith(longBreakMinutes: minutes);
    notifyListeners();
  }

  void setCyclesPerLongBreak(int cycles) {
    _send('SET CYCLES=$cycles');
    config = config.copyWith(cyclesPerLongBreak: cycles);
    notifyListeners();
  }

  void setWarningSeconds(int seconds) {
    _send('SET WARN_SEC=$seconds');
    config = config.copyWith(warningSeconds: seconds);
    notifyListeners();
  }

  void setIdlePerkMinutes(int minutes) {
    _send('SET PERK_MIN=$minutes');
    config = config.copyWith(idlePerkIntervalMinutes: minutes);
    notifyListeners();
  }

  void _handleLine(String line) {
    if (line.startsWith('STAT,')) {
      final parsed = StudyStatus.parse(line);
      if (parsed != null) {
        status = parsed;
        notifyListeners();
      }
      return;
    }
    if (line == 'OLED,INIT,OK') {
      oledReady = true;
      notifyListeners();
      return;
    }
    if (line == 'OLED,INIT,FAIL') {
      oledReady = false;
      notifyListeners();
      return;
    }
  }

  void _scheduleEarWiggle() {
    _earTimer?.cancel();
    final delay = Duration(seconds: 25 + _random.nextInt(50));
    _earTimer = Timer(delay, () {
      if (!connected) return;
      _send('EAR');
      _scheduleEarWiggle();
    });
  }

  @override
  void dispose() {
    _earTimer?.cancel();
    _healthTimer?.cancel();
    _lineSubscription?.cancel();
    _activeTransport?.disconnect();
    super.dispose();
  }
}
