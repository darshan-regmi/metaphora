import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class UserController {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();

  // Register a new user
  Future<Response> register(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Validate required fields
      if (data['username'] == null || data['email'] == null || data['password'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Username, email, and password are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if username or email already exists
      final existingUserByUsername = await _userRepository.getUserByUsername(data['username']);
      if (existingUserByUsername != null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Username already exists'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final existingUserByEmail = await _userRepository.getUserByEmail(data['email']);
      if (existingUserByEmail != null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Email already exists'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Create user
      final user = User(
        username: data['username'],
        email: data['email'],
        password: data['password'],
        profilePic: data['profile_pic'],
        bio: data['bio'],
      );
      
      final createdUser = await _userRepository.createUser(user);
      
      // Generate token
      final token = _authService.generateToken(createdUser);
      
      return Response.ok(
        jsonEncode({
          'message': 'User registered successfully',
          'user': {
            'id': createdUser.id,
            'username': createdUser.username,
            'email': createdUser.email,
            'profile_pic': createdUser.profilePic,
            'bio': createdUser.bio,
            'created_at': createdUser.createdAt?.toIso8601String(),
          },
          'token': token,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to register user: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Login user
  Future<Response> login(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Validate required fields
      if (data['email'] == null || data['password'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Email and password are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Authenticate user
      final user = await _userRepository.authenticateUser(data['email'], data['password']);
      if (user == null) {
        return Response.unauthorized(
          jsonEncode({'error': 'Invalid email or password'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Generate token
      final token = _authService.generateToken(user);
      
      return Response.ok(
        jsonEncode({
          'message': 'Login successful',
          'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'profile_pic': user.profilePic,
            'bio': user.bio,
            'created_at': user.createdAt?.toIso8601String(),
          },
          'token': token,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to login: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get user profile
  // Get user by ID
  Future<Response> getUserById(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      return Response.ok(
        jsonEncode({
          'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'profile_pic': user.profilePic,
            'bio': user.bio,
            'created_at': user.createdAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get user: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get user profile
  Future<Response> getProfile(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      return Response.ok(
        jsonEncode({
          'user': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'profile_pic': user.profilePic,
            'bio': user.bio,
            'created_at': user.createdAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get user profile: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Update user profile
  Future<Response> updateProfile(Request request) async {
    try {
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Get current user
      final currentUser = await _userRepository.getUserById(userId);
      if (currentUser == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if username is being changed and if it already exists
      if (data['username'] != null && data['username'] != currentUser.username) {
        final existingUser = await _userRepository.getUserByUsername(data['username']);
        if (existingUser != null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Username already exists'}),
            headers: {'content-type': 'application/json'},
          );
        }
      }
      
      // Check if email is being changed and if it already exists
      if (data['email'] != null && data['email'] != currentUser.email) {
        final existingUser = await _userRepository.getUserByEmail(data['email']);
        if (existingUser != null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Email already exists'}),
            headers: {'content-type': 'application/json'},
          );
        }
      }
      
      // Update user
      final updatedUser = currentUser.copyWith(
        username: data['username'] ?? currentUser.username,
        email: data['email'] ?? currentUser.email,
        profilePic: data['profile_pic'] ?? currentUser.profilePic,
        bio: data['bio'] ?? currentUser.bio,
      );
      
      await _userRepository.updateUser(updatedUser);
      
      return Response.ok(
        jsonEncode({
          'message': 'Profile updated successfully',
          'user': {
            'id': updatedUser.id,
            'username': updatedUser.username,
            'email': updatedUser.email,
            'profile_pic': updatedUser.profilePic,
            'bio': updatedUser.bio,
            'created_at': updatedUser.createdAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update profile: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Change password
  Future<Response> changePassword(Request request) async {
    try {
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Validate required fields
      if (data['current_password'] == null || data['new_password'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Current password and new password are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Get current user
      final currentUser = await _userRepository.getUserById(userId);
      if (currentUser == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Verify current password
      final authenticatedUser = await _userRepository.authenticateUser(
        currentUser.email,
        data['current_password'],
      );
      
      if (authenticatedUser == null) {
        return Response.unauthorized(
          jsonEncode({'error': 'Current password is incorrect'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Update password
      await _userRepository.updatePassword(userId, data['new_password']);
      
      return Response.ok(
        jsonEncode({'message': 'Password changed successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to change password: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Delete user account
  Future<Response> deleteAccount(Request request) async {
    try {
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      // Delete user
      await _userRepository.deleteUser(userId);
      
      return Response.ok(
        jsonEncode({'message': 'Account deleted successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete account: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
