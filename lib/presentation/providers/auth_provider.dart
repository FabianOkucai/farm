import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/mock_auth_service.dart';
import '../../core/services/base_auth_service.dart';
import '../../constants/config.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  static const bool useMockService = true; // Set to false to use real service

  final BaseAuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _error;

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

  void _init() {
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String district,
    required String village,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        fullName: displayName,
        phone: phone,
        district: district,
        village: village,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
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
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.updateProfile(
        displayName: displayName,
        phone: phone,
        district: district,
        village: village,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePassword(String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updatePassword(password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String district,
    required String village,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        district: district,
        village: village,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
