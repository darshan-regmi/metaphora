import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}

class AuthController with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  String? _token;
  String? get token => _token;
  
  bool get isAuthenticated => _token != null && _currentUser != null;
  
  // Initialize controller and check for existing token
  Future<bool> initialize() async {
    _setLoading(true);
    try {
      await _loadToken();
      if (_token != null) {
        final success = await _loadUserFromToken();
        if (success) {
          return true; // User is authenticated
        }
      }
      return false; // User needs to login
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await logout(); // Clear any invalid tokens
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _userRepository.authenticateUser(email, password);
      if (user == null) {
        return false;
      }
      
      _currentUser = user;
      _token = _authService.generateToken(user);
      await _saveToken(_token!);
      
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Register a new user
  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    try {
      // Check if email already exists
      final existingUserByEmail = await _userRepository.getUserByEmail(email);
      if (existingUserByEmail != null) {
        return false;
      }
      
      // Check if username already exists
      final existingUserByUsername = await _userRepository.getUserByUsername(username);
      if (existingUserByUsername != null) {
        return false;
      }
      
      // Create new user
      final newUser = User(
        username: username,
        email: email,
        password: password,
      );
      
      final createdUser = await _userRepository.createUser(newUser);
      _currentUser = createdUser;
      _token = _authService.generateToken(createdUser);
      await _saveToken(_token!);
      
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      // Check if the email exists in our system
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        return AuthResult(
          success: false,
          message: "No account found with this email address.",
        );
      }
      
      // Generate a temporary reset token
      final resetToken = _authService.generatePasswordResetToken(user);
      
      // In a real app, you would send an email with a link containing the token
      // For this demo, we'll just simulate the email sending
      await Future.delayed(const Duration(seconds: 1));
      
      return AuthResult(
        success: true,
        message: "Password reset instructions have been sent to your email.",
      );
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult(
        success: false,
        message: "An error occurred. Please try again later.",
      );
    } finally {
      _setLoading(false);
    }
  }
  
  // Reset password with token
  Future<AuthResult> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    try {
      // Verify the reset token
      final userId = _authService.verifyPasswordResetToken(token);
      if (userId == null) {
        return AuthResult(
          success: false,
          message: "Invalid or expired reset link. Please request a new one.",
        );
      }
      
      // Get the user
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return AuthResult(
          success: false,
          message: "User not found. Please contact support.",
        );
      }
      
      // Update the password
      await _userRepository.updatePassword(userId, newPassword);
      
      return AuthResult(
        success: true,
        message: "Password has been reset successfully. You can now log in with your new password.",
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      return AuthResult(
        success: false,
        message: "An error occurred. Please try again later.",
      );
    } finally {
      _setLoading(false);
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _clearToken();
      _currentUser = null;
      _token = null;
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({String? username, String? bio, String? profilePic}) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    try {
      final updatedUser = _currentUser!.copyWith(
        username: username,
        bio: bio,
        profilePic: profilePic,
      );
      
      final result = await _userRepository.updateUser(updatedUser);
      _currentUser = result;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    try {
      // Verify current password
      final user = await _userRepository.authenticateUser(
        _currentUser!.email, 
        currentPassword
      );
      
      if (user == null) {
        return false;
      }
      
      // Update password
      await _userRepository.updatePassword(_currentUser!.id!, newPassword);
      return true;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Private methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      // Verify token is still valid
      try {
        final payload = _authService.verifyToken(_token!);
        if (payload == null) {
          _token = null;
          await prefs.remove('auth_token');
        }
      } catch (e) {
        _token = null;
        await prefs.remove('auth_token');
      }
    }
  }
  
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  Future<bool> _loadUserFromToken() async {
    if (_token == null) return false;
    
    final payload = _authService.verifyToken(_token!);
    if (payload == null) {
      await _clearToken();
      _token = null;
      return false;
    }
    
    final userId = int.tryParse(payload['sub'] as String);
    if (userId == null) {
      await _clearToken();
      _token = null;
      return false;
    }
    
    _currentUser = await _userRepository.getUserById(userId);
    if (_currentUser == null) {
      await _clearToken();
      _token = null;
      return false;
    }
    
    notifyListeners();
    return true;
  }
}
