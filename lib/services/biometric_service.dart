import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static const _storage = FlutterSecureStorage();
  static const _enabledKey = 'biometric_enabled';

  static final _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isEnabled() async {
    return await _storage.read(key: _enabledKey) == 'true';
  }

  static Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _enabledKey, value: enabled ? 'true' : 'false');
  }

  /// Returns true if authenticated (or biometrics not enabled/available).
  static Future<bool> authenticate({String reason = 'Confirm your identity'}) async {
    if (!await isEnabled()) return true;
    if (!await isAvailable()) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Authenticate specifically for payment confirmation.
  static Future<bool> authenticateForPayment() =>
      authenticate(reason: 'Confirm identity to complete payment');
}
