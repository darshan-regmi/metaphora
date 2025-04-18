import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';

class AuthService {
  // Secret key for JWT signing (in production, this should be stored securely)
  static const String _secretKey = 'metaphora_poetry_app_secret_key';
  static const String _resetSecretKey = 'metaphora_password_reset_secret_key';
  
  // Token expiration time (24 hours)
  static const int _expirationInHours = 24;
  // Reset token expiration time (1 hour)
  static const int _resetExpirationInMinutes = 60;
  
  // Generate JWT token
  String generateToken(User user) {
    final now = DateTime.now();
    final expiry = now.add(Duration(hours: _expirationInHours));
    
    // Create header
    final header = {
      'alg': 'HS256',
      'typ': 'JWT'
    };
    
    // Create payload
    final payload = {
      'sub': user.id.toString(),
      'username': user.username,
      'email': user.email,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
    };
    
    // Encode header and payload
    final encodedHeader = base64Url.encode(utf8.encode(jsonEncode(header)));
    final encodedPayload = base64Url.encode(utf8.encode(jsonEncode(payload)));
    
    // Create signature
    final data = '$encodedHeader.$encodedPayload';
    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final digest = hmac.convert(utf8.encode(data));
    final signature = base64Url.encode(digest.bytes);
    
    // Return complete JWT token
    return '$encodedHeader.$encodedPayload.$signature';
  }
  
  // Generate password reset token
  String generatePasswordResetToken(User user) {
    final now = DateTime.now();
    final expiry = now.add(Duration(minutes: _resetExpirationInMinutes));
    
    // Create header
    final header = {
      'alg': 'HS256',
      'typ': 'JWT'
    };
    
    // Create payload
    final payload = {
      'sub': user.id.toString(),
      'email': user.email,
      'purpose': 'password_reset',
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
    };
    
    // Encode header and payload
    final encodedHeader = base64Url.encode(utf8.encode(jsonEncode(header)));
    final encodedPayload = base64Url.encode(utf8.encode(jsonEncode(payload)));
    
    // Create signature with a different secret key
    final data = '$encodedHeader.$encodedPayload';
    final hmac = Hmac(sha256, utf8.encode(_resetSecretKey));
    final digest = hmac.convert(utf8.encode(data));
    final signature = base64Url.encode(digest.bytes);
    
    // Return complete JWT token
    return '$encodedHeader.$encodedPayload.$signature';
  }
  
  // Verify JWT token
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      final encodedHeader = parts[0];
      final encodedPayload = parts[1];
      final providedSignature = parts[2];
      
      // Verify signature
      final data = '$encodedHeader.$encodedPayload';
      final hmac = Hmac(sha256, utf8.encode(_secretKey));
      final digest = hmac.convert(utf8.encode(data));
      final calculatedSignature = base64Url.encode(digest.bytes);
      
      if (providedSignature != calculatedSignature) {
        return null;
      }
      
      // Decode payload
      final payloadJson = utf8.decode(base64Url.decode(base64Url.normalize(encodedPayload)));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      
      // Check expiration
      final expiry = DateTime.fromMillisecondsSinceEpoch((payload['exp'] as int) * 1000);
      if (expiry.isBefore(DateTime.now())) {
        return null;
      }
      
      return payload;
    } catch (e) {
      return null;
    }
  }
  
  // Verify password reset token and return user ID if valid
  int? verifyPasswordResetToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      final encodedHeader = parts[0];
      final encodedPayload = parts[1];
      final providedSignature = parts[2];
      
      // Verify signature with the reset secret key
      final data = '$encodedHeader.$encodedPayload';
      final hmac = Hmac(sha256, utf8.encode(_resetSecretKey));
      final digest = hmac.convert(utf8.encode(data));
      final calculatedSignature = base64Url.encode(digest.bytes);
      
      if (providedSignature != calculatedSignature) {
        return null;
      }
      
      // Decode payload
      final payloadJson = utf8.decode(base64Url.decode(base64Url.normalize(encodedPayload)));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      
      // Check purpose
      if (payload['purpose'] != 'password_reset') {
        return null;
      }
      
      // Check expiration
      final expiry = DateTime.fromMillisecondsSinceEpoch((payload['exp'] as int) * 1000);
      if (expiry.isBefore(DateTime.now())) {
        return null;
      }
      
      // Return user ID
      return int.tryParse(payload['sub'] as String);
    } catch (e) {
      return null;
    }
  }
  
  // Extract user ID from token
  int? getUserIdFromToken(String token) {
    final payload = verifyToken(token);
    if (payload == null) {
      return null;
    }
    
    return int.tryParse(payload['sub'] as String);
  }
}
