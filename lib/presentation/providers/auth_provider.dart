// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/mock_auth_service.dart';
import '../../core/services/base_auth_service.dart';
import '../../constants/config.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  static const bool useMockService = false; // Set to true for testing

  final BaseAuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AuthProvider({BaseAuthService? authService})
      : _authService = authService ??
      (useMockService
          ? MockAuthService()
          : AuthService(baseUrl: AppConfig.apiBaseUrl)) {
    _init();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    try {
      // Initialize the auth service
      await _authService.init();

      // Check if user is already authenticated
      if (_authService.isAuthenticated) {
        _user = await _authService.getCurrentUser();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize authentication: ${e.toString()}';
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String district,
    required String village,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        fullName: displayName,
        phone: phone,
        district: district,
        village: village,
      );

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      rethrow;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String phone,
    required String district,
    required String village,
    File? profileImage,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      String? photoURL;

      // Upload profile image if provided
      if (profileImage != null) {
        // You'll need to implement image upload service
        // photoURL = await _uploadProfileImage(profileImage);
      }

      _user = await _authService.updateProfile(
        displayName: displayName,
        phone: phone,
        district: district,
        village: village,
        photoURL: photoURL,
      );

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      rethrow;
    }
  }

  Future<void> updatePassword(String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updatePassword(password);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_parseError(e));
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    try {
      await _authService.refreshToken();
      // Optionally refresh user data
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Handle token refresh failure
      _setError('Session expired. Please log in again.');
      _user = null;
      notifyListeners();
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Exception:')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }
    return error.toString();
  }

  void clearError() {
    _clearError();
  }

  // Legacy methods for backward compatibility
  Future<void> logout() => signOut();

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String district,
    required String village,
  }) => signUp(
    email: email,
    password: password,
    displayName: fullName,
    phone: phone,
    district: district,
    village: village,
  );
}