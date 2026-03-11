import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Cryptographic utilities for EduFlow
class CryptoUtils {
  CryptoUtils._();

  /// Hash a phone number using SHA-256
  /// This is used to store phone numbers securely without exposing the actual number
  static String hashPhoneNumber(String phoneNumber) {
    // Normalize phone number: remove spaces, dashes, and country code prefix if any
    final normalized = phoneNumber
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('+', '');
    
    // Convert to bytes and hash
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  /// Generate a unique device identifier
  /// In production, this would use device_info_plus to get a proper device ID
  static String generateDeviceId(String phoneHash) {
    final bytes = utf8.encode('device_$phoneHash');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  /// Verify a phone number against a hash
  static bool verifyPhoneNumber(String phoneNumber, String hash) {
    final computedHash = hashPhoneNumber(phoneNumber);
    return computedHash == hash;
  }

  /// Generate a random OTP (6 digits)
  static String generateOtp() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final otp = (random % 900000) + 100000;
    return otp.toString();
  }

  /// Validate OTP format
  static bool isValidOtp(String otp) {
    if (otp.length != 6) return false;
    return int.tryParse(otp) != null;
  }
}
