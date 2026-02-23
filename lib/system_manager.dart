import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SystemManager {

  // Platform channel
  static const MethodChannel _channel =
      MethodChannel('com.scamkavatch/overlay');


  // ================= PREMIUM =================

  /// Sync premium status to Android
  static Future<void> setPremium(bool enabled) async {

    try {

      await _channel.invokeMethod(
        'setPremium',
        enabled,
      );

    } on PlatformException catch (e) {

      debugPrint(
          'SystemManager setPremium error: ${e.message}');

    } catch (e) {

      debugPrint(
          'SystemManager setPremium unexpected error: $e');
    }
  }


  // ================= PERMISSIONS =================

  /// Check if Accessibility + Notification + Overlay are enabled
  /// Returns true if setup still needed
  static Future<bool> checkPermissions() async {

    try {

      final bool? result =
          await _channel.invokeMethod<bool>(
              'checkPermissions');

      return result ?? true;

    } on PlatformException catch (e) {

      debugPrint(
          'SystemManager checkPermissions error: ${e.message}');

      return true;

    } catch (e) {

      debugPrint(
          'SystemManager checkPermissions unexpected error: $e');

      return true;
    }
  }


  // ================= IMPORTANT CHANGE =================
  // DO NOT OPEN SETTINGS AUTOMATICALLY
  // Play Store compliant version

  static Future<void> requestPermissionSetup() async {

    debugPrint(
        'Permission setup must be done manually by user via Settings.');

    // Intentionally not opening settings automatically
  }


  // ================= PROTECTION =================

  /// Enable scam protection services (only works if permissions enabled)
  static Future<void> enableProtection() async {

    try {

      await _channel.invokeMethod(
          'enableProtection');

    } on PlatformException catch (e) {

      debugPrint(
          'SystemManager enableProtection error: ${e.message}');

    } catch (e) {

      debugPrint(
          'SystemManager enableProtection unexpected error: $e');
    }
  }


  static Future<void> disableProtection() async {

    try {

      await _channel.invokeMethod(
          'disableProtection');

    } catch (e) {

      debugPrint(
          'SystemManager disableProtection error: $e');
    }
  }


  // ================= SYSTEM =================

  static Future<bool> isSystemReady() async {

    try {

      final bool? result =
          await _channel.invokeMethod<bool>(
              'checkSystemReady');

      return result ?? false;

    } on PlatformException catch (e) {

      debugPrint(
          'SystemManager checkSystemReady error: ${e.message}');

      return false;

    } catch (e) {

      debugPrint(
          'SystemManager checkSystemReady unexpected error: $e');

      return false;
    }
  }


  static Future<void> testNotification() async {

    try {

      await _channel.invokeMethod(
          'testNotification');

    } on PlatformException catch (e) {

      debugPrint(
          'SystemManager testNotification error: ${e.message}');
    }
  }

}
