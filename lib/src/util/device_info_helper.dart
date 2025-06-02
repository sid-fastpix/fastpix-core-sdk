import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

enum DeviceType { phone, tablet, unknown }

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final Map<String, dynamic> info = {
      'osName': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'deviceManufacturer': '',
      'deviceModel': '',
      'deviceName': '',
      'deviceType': DeviceType.unknown.name,
    };

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      info['deviceManufacturer'] = androidInfo.manufacturer;
      info['deviceModel'] = androidInfo.model;
      info['deviceName'] = androidInfo.device;
      info['deviceType'] = _getAndroidDeviceType(androidInfo);
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      info['deviceManufacturer'] = 'Apple';
      info['deviceModel'] = iosInfo.utsname.machine;
      info['deviceName'] = iosInfo.name;
      info['deviceType'] = _getIOSDeviceType(iosInfo);
    }

    return info;
  }

  static String _getAndroidDeviceType(AndroidDeviceInfo info) {
    // A basic heuristic to determine tablet vs phone
    if (info.systemFeatures.contains('android.hardware.type.television')) {
      return 'tv';
    } else if (info.systemFeatures.contains('android.hardware.type.watch')) {
      return 'watch';
    } else if (info.systemFeatures.contains('android.hardware.touchscreen')) {
      return 'phone';
    }
    return DeviceType.unknown.name;
  }

  static String _getIOSDeviceType(IosDeviceInfo info) {
    if (info.name.toLowerCase().contains("ipad")) {
      return DeviceType.tablet.name;
    } else if (info.name.toLowerCase().contains("iphone")) {
      return DeviceType.phone.name;
    }
    return DeviceType.unknown.name;
  }
}