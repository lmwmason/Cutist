import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'device_transport.dart';

class BluetoothTransport implements DeviceTransport {
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<String> _lineController =
      StreamController<String>.broadcast();
  final StringBuffer _lineBuffer = StringBuffer();

  @override
  TransportKind get kind => TransportKind.bluetooth;

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  bool get isConnected => _connection?.isConnected ?? false;

  @override
  Future<List<TransportDevice>> listDevices() async {
    final bluetooth = FlutterBluetoothSerial.instance;
    final enabled = await bluetooth.isEnabled ?? false;
    if (!enabled) {
      await bluetooth.requestEnable();
    }
    final bonded = await bluetooth.getBondedDevices();
    return bonded
        .map((device) => TransportDevice(
              id: device.address,
              label: device.name ?? device.address,
              owner: this,
            ))
        .toList();
  }

  @override
  Future<void> connect(TransportDevice device) async {
    await disconnect();
    final connection = await BluetoothConnection.toAddress(device.id);
    _connection = connection;
    _subscription = connection.input?.listen(_onChunk, onDone: () {
      disconnect();
    });
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
    _connection?.output.add(Uint8List.fromList(utf8.encode('$line\n')));
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _connection?.close();
    _connection = null;
    _lineBuffer.clear();
  }
}
