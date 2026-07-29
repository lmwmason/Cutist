import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:usb_serial/usb_serial.dart';

import 'device_transport.dart';

class UsbSerialTransport implements DeviceTransport {
  static const int baudRate = 9600;

  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<String> _lineController =
      StreamController<String>.broadcast();
  final StringBuffer _lineBuffer = StringBuffer();

  @override
  TransportKind get kind => TransportKind.usb;

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  bool get isConnected => _port != null;

  @override
  Future<List<TransportDevice>> listDevices() async {
    final devices = await UsbSerial.listDevices();
    return devices.map((device) {
      final name = device.productName?.trim();
      final label = (name != null && name.isNotEmpty)
          ? '$name (USB)'
          : '${device.deviceName} (USB)';
      return TransportDevice(id: device.deviceName, label: label, owner: this);
    }).toList();
  }

  @override
  Future<void> connect(TransportDevice device) async {
    await disconnect();
    final devices = await UsbSerial.listDevices();
    UsbDevice? target;
    for (final candidate in devices) {
      if (candidate.deviceName == device.id) {
        target = candidate;
        break;
      }
    }
    if (target == null) {
      throw StateError('USB device not found: ${device.id}');
    }
    final port = await target.create();
    if (port == null || !await port.open()) {
      throw StateError('Could not open USB port: ${device.id}');
    }
    await port.setPortParameters(
      baudRate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );
    _port = port;
    _subscription = port.inputStream?.listen(_onChunk);
  }

  void _onChunk(Uint8List chunk) {
    _lineBuffer.write(utf8.decode(chunk, allowMalformed: true));
    _drainLines();
  }

  void _drainLines() {
    var content = _lineBuffer.toString();
    var index = content.indexOf('\n');
    while (index != -1) {
      final line = content.substring(0, index).replaceAll('\r', '');
      if (line.isNotEmpty) {
        _lineController.add(line);
      }
      content = content.substring(index + 1);
      index = content.indexOf('\n');
    }
    _lineBuffer
      ..clear()
      ..write(content);
  }

  @override
  void send(String line) {
    _port?.write(Uint8List.fromList(utf8.encode('$line\n')));
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _port?.close();
    _port = null;
    _lineBuffer.clear();
  }
}
