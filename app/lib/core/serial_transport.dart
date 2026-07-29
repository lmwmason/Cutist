import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

import 'device_transport.dart';

class SerialTransport implements DeviceTransport {
  static const int baudRate = 9600;

  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<String> _lineController =
      StreamController<String>.broadcast();
  final StringBuffer _lineBuffer = StringBuffer();

  @override
  TransportKind get kind => TransportKind.usb;

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  bool get isConnected => _port?.isOpen ?? false;

  @override
  Future<List<TransportDevice>> listDevices() async {
    return SerialPort.availablePorts.map((name) {
      final port = SerialPort(name);
      final label = port.description ?? name;
      port.dispose();
      return TransportDevice(id: name, label: '$name ($label)', owner: this);
    }).toList();
  }

  @override
  Future<void> connect(TransportDevice device) async {
    await disconnect();
    final port = SerialPort(device.id);
    if (!port.openReadWrite()) {
      final error = SerialPort.lastError;
      port.dispose();
      throw StateError('Could not open port: ${error?.message ?? device.id}');
    }
    port.config = SerialPortConfig()
      ..baudRate = baudRate
      ..bits = 8
      ..parity = SerialPortParity.none
      ..stopBits = 1
      ..setFlowControl(SerialPortFlowControl.none);
    _port = port;
    _reader = SerialPortReader(port);
    _subscription = _reader!.stream.listen(_onChunk);
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
    _reader?.close();
    _reader = null;
    _port?.close();
    _port?.dispose();
    _port = null;
    _lineBuffer.clear();
  }
}
