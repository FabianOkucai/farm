import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'base_auth_service.dart';

class AuthService implements BaseAuthService {
  final String baseUrl;
  final http.Client _httpClient;

  AuthService({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  // Store the auth token
  String? _token;
  String? _refreshToken;
  DateTime? _tokenExpiresAt;

  // Get the current token
  String? get token => _token;

  // Check if user is authenticated
  bool get isAuthenticated => _token != null;

  // Initialize the auth service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    final expiryString = prefs.getString('token_expires_at');
    if (expiryString != null) {
      _tokenExpiresAt = DateTime.parse(expiryString);
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
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': fullName,
          'phone': phone,
          'email': email,
          'password': password,
          'district': district,
          'village': village,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Save tokens
          _token = data['data']['access_token'];
          _refreshToken = data['data']['refresh_token'];
          _tokenExpiresAt = DateTime.parse(data['data']['token_expires_at']);

          // Save to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _token!);
          await prefs.setString('refresh_token', _refreshToken!);
          await prefs.setString(
            'token_expires_at',
            _tokenExpiresAt!.toIso8601String(),
          );

          // Create and return user object
          return User.fromJson({
            'id': data['data']['farmer_id'],
            'email': email,
            'fullName': fullName,
            'phoneNumber': phone,
            'district': district,
            'village': village,
          });
        } else {
          throw Exception(data['message'] ?? 'Registration failed');
        }
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<User> signIn({required String email, required String password}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Save tokens
          _token = data['data']['access_token'];
          _refreshToken = data['data']['refresh_token'];
          _tokenExpiresAt = DateTime.parse(data['data']['token_expires_at']);

          // Save to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _token!);
          await prefs.setString('refresh_token', _refreshToken!);
          await prefs.setString(
            'token_expires_at',
            _tokenExpiresAt!.toIso8601String(),
          );

          // Get user profile
          final userResponse = await _httpClient.get(
            Uri.parse('$baseUrl/farmers/profile/${data['data']['farmer_id']}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            },
          );

          if (userResponse.statusCode == 200) {
            final userData = jsonDecode(userResponse.body);
            return User.fromJson(userData['data']);
          } else {
            throw Exception('Failed to get user profile');
          }
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Update tokens
          _token = data['data']['access_token'];
          _refreshToken = data['data']['refresh_token'];
          _tokenExpiresAt = DateTime.parse(data['data']['token_expires_at']);

          // Save to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _token!);
          await prefs.setString('refresh_token', _refreshToken!);
          await prefs.setString(
            'token_expires_at',
            _tokenExpiresAt!.toIso8601String(),
          );
        } else {
          throw Exception(data['message'] ?? 'Token refresh failed');
        }
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> signOut() async {
    _token = null;
    _refreshToken = null;
    _tokenExpiresAt = null;

    // Clear tokens from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expires_at');
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    if (_token == null) return null;

    // In a real app, you would make an API call to get the user data
    // For demo purposes, we'll return a mock user

    final userData = {
      'id': '1',
      'email': 'user@example.com',
      'fullName': 'Demo User',
      'phoneNumber': null,
      'address': null,
      'profileImageUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    return User.fromJson(userData);
  }

  // Stream to listen for auth changes
  Stream<User?> get user {
    // In a real app with Firebase, this would be a stream from Firebase Auth
    // For demo purposes, we'll create a simple stream
    return Stream.fromFuture(getCurrentUser());
  }

  // Update profile
  Future<User> updateProfile({
    required String displayName,
    required String phone,
    required String district,
    required String village,
    String? photoURL,
  }) async {
    if (_token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/farmers/profile'),
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data']);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Update password
  Future<void> updatePassword(String password) async {
    // In a real app, you would make an API call to update the password
    // For demo purposes, we'll just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    // In a real app, you would make an API call to send a password reset email
    // For demo purposes, we'll just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> logout() async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}
