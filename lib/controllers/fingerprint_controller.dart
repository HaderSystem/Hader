import 'package:local_auth/local_auth.dart';
import 'dart:convert'; // لتحويل النص إلى Bytes
import 'package:crypto/crypto.dart'; // لعمل SHA-256 Hash

class FingerprintController {
  final LocalAuthentication auth = LocalAuthentication();

  /// تتحقق من بصمة الإصبع
  Future<String?> authenticateAndHash(String studentId) async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Error during authentication: $e');
      return null;
    }

    if (authenticated) {
      // بعد النجاح، نعمل SHA-256 على الـ studentId
      var bytes = utf8.encode(studentId);
      var digest = sha256.convert(bytes);

      print('Authentication successful!');
      print('SHA-256 Hashed ID: ${digest.toString()}');

      return digest.toString(); // نرجع الهاش
    } else {
      print('Authentication failed');
      return null;
    }
  }
}
