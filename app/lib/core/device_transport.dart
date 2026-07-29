enum TransportKind { usb, bluetooth }

class TransportDevice {
  final String id;
  final String label;
  final DeviceTransport owner;

  const TransportDevice({required this.id, required this.label, required this.owner});
}

abstract class DeviceTransport {
  TransportKind get kind;
  Stream<String> get lines;
  bool get isConnected;

  Future<List<TransportDevice>> listDevices();
  Future<void> connect(TransportDevice device);
  Future<void> disconnect();
  void send(String line);
}
