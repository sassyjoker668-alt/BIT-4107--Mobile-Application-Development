import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  static final LocalAuthentication _auth =
  LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      final isDeviceSupported =
      await _auth.isDeviceSupported();
      if (!isDeviceSupported) return false;
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<BiometricType>>
  getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  static Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;
      return await _auth.authenticate(
        localizedReason:
        'Scan your fingerprint to access Budget App',
      );
    } on PlatformException {
      return false;
    }
  }
}