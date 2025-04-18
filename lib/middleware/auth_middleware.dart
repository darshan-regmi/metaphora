import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/auth_service.dart';

class AuthMiddleware {
  final AuthService _authService = AuthService();

  // Middleware to check if the request is authenticated
  Middleware authenticate() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Get the authorization header
        final authHeader = request.headers['authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(
            jsonEncode({'error': 'Unauthorized: No valid token provided'}),
            headers: {'content-type': 'application/json'},
          );
        }

        // Extract the token
        final token = authHeader.substring(7);
        final payload = _authService.verifyToken(token);
        
        if (payload == null) {
          return Response.unauthorized(
            jsonEncode({'error': 'Unauthorized: Invalid or expired token'}),
            headers: {'content-type': 'application/json'},
          );
        }

        // Add the user ID to the request context
        final userId = int.parse(payload['sub'] as String);
        final updatedRequest = request.change(context: {'userId': userId});
        
        // Continue to the handler
        return innerHandler(updatedRequest);
      };
    };
  }
}
