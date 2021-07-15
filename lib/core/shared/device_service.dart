import 'dart:io';
import 'package:device_info/device_info.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  late String _deviceIdentifier;

  factory DeviceService() {
    _instance._init();
    return _instance;
  }

  String get deviceIdentifier => _deviceIdentifier;

  Future<void> _init() async {
    if (Platform.isAndroid) {
      var info = await _deviceInfoPlugin.androidInfo;
      _deviceIdentifier = info.androidId;
    } else if (Platform.isIOS) {
      var info = await _deviceInfoPlugin.iosInfo;
      _deviceIdentifier = info.identifierForVendor;
    }
  }
}
