// lib/core/services/auth_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'base_auth_service.dart';

class AuthService implements BaseAuthService {
  final String baseUrl;
  final http.Client _httpClient;
  final StreamController<User?> _userController = StreamController<User?>.broadcast();

  AuthService({required this.baseUrl, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client() {
    debugPrint('🔧 AuthService initialized with baseUrl: $baseUrl');
  }

  // Store the auth token
  String? _token;
  String? _refreshToken;
  DateTime? _tokenExpiresAt;
  User? _currentUser;

  // Get the current token
  String? get token => _token;

  // Check if user is authenticated
  bool get isAuthenticated => _token != null && !_isTokenExpired();

  // Stream to listen for auth changes
  Stream<User?> get user => _userController.stream;

  // Initialize the auth service
  Future<void> init() async {
    debugPrint('🚀 AuthService.init() called');

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      final expiryString = prefs.getString('token_expires_at');

      debugPrint('📱 Stored token exists: ${_token != null}');
      debugPrint('📱 Stored refresh token exists: ${_refreshToken != null}');

      if (expiryString != null) {
        _tokenExpiresAt = DateTime.parse(expiryString);
        debugPrint('📱 Token expires at: $_tokenExpiresAt');
      }

      // If we have a valid token, get current user
      if (isAuthenticated) {
        debugPrint('✅ User is authenticated, fetching current user');
        try {
          _currentUser = await _fetchCurrentUser();
          _userController.add(_currentUser);
          debugPrint('✅ Current user fetched successfully: ${_currentUser?.email}');
        } catch (e) {
          debugPrint('❌ Error fetching current user: $e');
          // Token might be invalid, clear it
          await _clearTokens();
        }
      } else {
        debugPrint('❌ User is not authenticated');
      }
    } catch (e) {
      debugPrint('❌ Error during AuthService.init(): $e');
    }
  }

  // Register a new user
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String district,
    required String village,
  }) async {
    final endpoint = '$baseUrl/auth/register';
    debugPrint('🔐 Starting registration process');
    debugPrint('📡 Endpoint: $endpoint');
    debugPrint('📧 Email: $email');
    debugPrint('👤 Name: $fullName');
    debugPrint('📞 Phone: $phone');
    debugPrint('🏘️ District: $district, Village: $village');

    final requestBody = {
      'name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'district': district,
      'village': village,
    };

    debugPrint('📦 Request body: ${jsonEncode(requestBody)}');

    try {
      debugPrint('🌐 Making HTTP POST request...');

      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏰ Request timed out after 30 seconds');
          throw TimeoutException('Request timed out', const Duration(seconds: 30));
        },
      );

      debugPrint('📥 Response received');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📋 Response Headers: ${response.headers}');
      debugPrint('📄 Response Body: ${response.body}');

      final data = _handleResponse(response);

      if (data['status'] == 'success') {
        debugPrint('✅ Registration successful');
        await _saveTokens(data['data']);
        _currentUser = await _fetchCurrentUser();
        _userController.add(_currentUser);
        debugPrint('✅ User registered and logged in: ${_currentUser?.email}');
        return _currentUser!;
      } else {
        debugPrint('❌ Registration failed: ${data['message']}');
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } on SocketException catch (e) {
      debugPrint('🔌 Socket Exception: $e');
      debugPrint('🔌 This usually means network connectivity issues or the server is unreachable');
      throw Exception('Network error. Please check your internet connection and try again.');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Exception: $e');
      throw Exception('Request timed out. Please check your internet connection and try again.');
    } on http.ClientException catch (e) {
      debugPrint('🌐 HTTP Client Exception: $e');
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException catch (e) {
      debugPrint('📋 Format Exception (likely invalid JSON): $e');
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      debugPrint('❌ Unexpected error during registration: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      throw Exception('Registration failed: ${_getErrorMessage(e)}');
    }
  }

  // Login user
  Future<User> signIn({required String email, required String password}) async {
    final endpoint = '$baseUrl/auth/login';
    debugPrint('🔐 Starting login process');
    debugPrint('📡 Endpoint: $endpoint');
    debugPrint('📧 Email: $email');

    final requestBody = {'email': email, 'password': password};
    debugPrint('📦 Request body: ${jsonEncode(requestBody)}');

    try {
      debugPrint('🌐 Making HTTP POST request...');

      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏰ Login request timed out after 30 seconds');
          throw TimeoutException('Request timed out', const Duration(seconds: 30));
        },
      );

      debugPrint('📥 Login response received');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📋 Response Headers: ${response.headers}');
      debugPrint('📄 Response Body: ${response.body}');

      final data = _handleResponse(response);

      if (data['status'] == 'success') {
        debugPrint('✅ Login successful');
        await _saveTokens(data['data']);
        _currentUser = await _fetchCurrentUser();
        _userController.add(_currentUser);
        debugPrint('✅ User logged in: ${_currentUser?.email}');
        return _currentUser!;
      } else {
        debugPrint('❌ Login failed: ${data['message']}');
        throw Exception(data['message'] ?? 'Login failed');
      }
    } on SocketException catch (e) {
      debugPrint('🔌 Socket Exception during login: $e');
      throw Exception('Network error. Please check your internet connection and try again.');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Exception during login: $e');
      throw Exception('Request timed out. Please check your internet connection and try again.');
    } on http.ClientException catch (e) {
      debugPrint('🌐 HTTP Client Exception during login: $e');
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException catch (e) {
      debugPrint('📋 Format Exception during login: $e');
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      debugPrint('❌ Unexpected error during login: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      throw Exception('Login failed: ${_getErrorMessage(e)}');
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      debugPrint('❌ No refresh token available');
      throw Exception('No refresh token available');
    }

    final endpoint = '$baseUrl/auth/refresh';
    debugPrint('🔄 Refreshing token');
    debugPrint('📡 Endpoint: $endpoint');

    try {
      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': _refreshToken}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏰ Token refresh timed out');
          throw TimeoutException('Request timed out', const Duration(seconds: 30));
        },
      );

      debugPrint('📥 Token refresh response received');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      final data = _handleResponse(response);

      if (data['status'] == 'success') {
        debugPrint('✅ Token refreshed successfully');
        await _saveTokens(data['data']);
      } else {
        debugPrint('❌ Token refresh failed: ${data['message']}');
        throw Exception(data['message'] ?? 'Token refresh failed');
      }
    } on SocketException catch (e) {
      debugPrint('🔌 Socket Exception during token refresh: $e');
      await _clearTokens();
      throw Exception('Network error. Please check your internet connection.');
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout during token refresh: $e');
      await _clearTokens();
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      debugPrint('🌐 HTTP Client Exception during token refresh: $e');
      await _clearTokens();
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      debugPrint('❌ Error during token refresh: $e');
      await _clearTokens();
      throw Exception('Token refresh failed: ${_getErrorMessage(e)}');
    }
  }

  // Logout user
  Future<void> signOut() async {
    debugPrint('🚪 Starting logout process');

    try {
      if (_token != null) {
        final endpoint = '$baseUrl/auth/logout';
        debugPrint('📡 Logout endpoint: $endpoint');

        await _httpClient.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 10));

        debugPrint('✅ Server logout successful');
      }
    } catch (e) {
      debugPrint('⚠️ Server logout failed (continuing with local logout): $e');
    } finally {
      await _clearTokens();
      _currentUser = null;
      _userController.add(null);
      debugPrint('✅ Local logout completed');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    debugPrint('👤 Getting current user');

    if (!isAuthenticated) {
      debugPrint('❌ User is not authenticated');
      return null;
    }

    if (_currentUser != null) {
      debugPrint('✅ Returning cached user: ${_currentUser?.email}');
      return _currentUser;
    }

    try {
      _currentUser = await _fetchCurrentUser();
      debugPrint('✅ Current user fetched: ${_currentUser?.email}');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ Error fetching current user: $e');
      await _clearTokens();
      return null;
    }
  }

  // Update profile
  Future<User> updateProfile({
    required String displayName,
    required String phone,
    required String district,
    required String village,
    String? photoURL,
  }) async {
    if (!isAuthenticated) {
      debugPrint('❌ Not authenticated for profile update');
      throw Exception('Not authenticated');
    }

    final endpoint = '$baseUrl/farmers/profile';
    debugPrint('👤 Updating profile');
    debugPrint('📡 Endpoint: $endpoint');

    try {
      final response = await _httpClient.put(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'name': displayName,
          'phone': phone,
          'district': district,
          'village': village,
          if (photoURL != null) 'profile_image_url': photoURL,
        }),
      );

      debugPrint('📥 Profile update response: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      final data = _handleResponse(response);

      if (data['status'] == 'success') {
        _currentUser = User.fromJson(data['data']);
        _userController.add(_currentUser);
        debugPrint('✅ Profile updated successfully');
        return _currentUser!;
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String password) async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final endpoint = '$baseUrl/auth/password';
    debugPrint('🔐 Updating password');
    debugPrint('📡 Endpoint: $endpoint');

    try {
      final response = await _httpClient.put(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'password': password}),
      );

      debugPrint('📥 Password update response: ${response.statusCode}');
      final data = _handleResponse(response);

      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to update password');
      }
      debugPrint('✅ Password updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating password: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    final endpoint = '$baseUrl/auth/reset-password';
    debugPrint('🔄 Resetting password for: $email');
    debugPrint('📡 Endpoint: $endpoint');

    try {
      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      debugPrint('📥 Password reset response: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');

      final data = _handleResponse(response);

      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to send reset email');
      }
      debugPrint('✅ Password reset email sent');
    } catch (e) {
      debugPrint('❌ Error during password reset: $e');
      rethrow;
    }
  }

  // Private helper methods
  Future<User> _fetchCurrentUser() async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated');
    }

    // Check if token needs refresh
    if (_isTokenExpired()) {
      debugPrint('🔄 Token expired, refreshing...');
      await refreshToken();
    }

    final endpoint = '$baseUrl/farmers/profile';
    debugPrint('👤 Fetching current user profile');
    debugPrint('📡 Endpoint: $endpoint');

    final response = await _httpClient.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    debugPrint('📥 User profile response: ${response.statusCode}');
    debugPrint('📄 Response body: ${response.body}');

    final data = _handleResponse(response);

    if (data['status'] == 'success') {
      return User.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to get user profile');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('🔍 Handling response with status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint('❌ Error parsing JSON response: $e');
        debugPrint('📄 Raw response: ${response.body}');
        throw FormatException('Invalid JSON response from server');
      }
    } else if (response.statusCode == 401) {
      debugPrint('🔐 Unauthorized (401)');
      throw Exception('Invalid credentials');
    } else if (response.statusCode == 403) {
      debugPrint('🚫 Forbidden (403)');
      throw Exception('Access forbidden');
    } else if (response.statusCode == 404) {
      debugPrint('🔍 Not Found (404)');
      throw Exception('Resource not found');
    } else if (response.statusCode >= 500) {
      debugPrint('🔥 Server Error (${response.statusCode})');
      throw Exception('Server error. Please try again later.');
    } else {
      debugPrint('❌ Unexpected status code: ${response.statusCode}');
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> tokenData) async {
    debugPrint('💾 Saving tokens to local storage');

    _token = tokenData['access_token'];
    _refreshToken = tokenData['refresh_token'];
    _tokenExpiresAt = DateTime.parse(tokenData['token_expires_at']);

    debugPrint('🔑 Access token saved: ${_token?.substring(0, 10)}...');
    debugPrint('🔄 Refresh token saved: ${_refreshToken?.substring(0, 10)}...');
    debugPrint('⏰ Token expires at: $_tokenExpiresAt');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _token!);
    await prefs.setString('refresh_token', _refreshToken!);
    await prefs.setString('token_expires_at', _tokenExpiresAt!.toIso8601String());

    debugPrint('✅ Tokens saved to SharedPreferences');
  }

  Future<void> _clearTokens() async {
    debugPrint('🗑️ Clearing tokens from local storage');

    _token = null;
    _refreshToken = null;
    _tokenExpiresAt = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expires_at');

    debugPrint('✅ Tokens cleared from SharedPreferences');
  }

  bool _isTokenExpired() {
    if (_tokenExpiresAt == null) return true;
    final isExpired = DateTime.now().isAfter(_tokenExpiresAt!.subtract(const Duration(minutes: 5)));
    if (isExpired) {
      debugPrint('⏰ Token is expired');
    }
    return isExpired;
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Exception:')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }
    return error.toString();
  }

  void dispose() {
    debugPrint('🔌 Disposing AuthService');
    _userController.close();
  }
}