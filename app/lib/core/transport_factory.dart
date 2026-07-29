import 'dart:io';

import 'bluetooth_transport.dart';
import 'device_transport.dart';
import 'serial_transport.dart';
import 'usb_serial_transport.dart';

List<DeviceTransport> createTransports() {
  if (Platform.isAndroid) {
    return [UsbSerialTransport(), BluetoothTransport()];
  }
  return [SerialTransport()];
}
