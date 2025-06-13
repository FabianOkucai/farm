import 'dart:async';
import '../models/user.dart';
import 'base_auth_service.dart';

class MockAuthService implements BaseAuthService {
  // Store the auth token
  String? _token;
  String? _refreshToken;
  DateTime? _tokenExpiresAt;

  // Mock user storage
  User? _currentUser;

  // Get the current token
  String? get token => _token;

  // Check if user is authenticated
  bool get isAuthenticated => _token != null;

  // Initialize the auth service
  Future<void> init() async {
    // No initialization needed for mock service
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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Create mock tokens
    _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    _refreshToken =
        'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    _tokenExpiresAt = DateTime.now().add(const Duration(hours: 1));

    // Create and return mock user
    _currentUser = User(
      id: 'f${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      phone: phone,
      district: district,
      village: village,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _currentUser!;
  }

  // Login user
  Future<User> signIn({required String email, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Validate credentials (mock validation)
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Invalid credentials');
    }

    // Create mock tokens
    _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    _refreshToken =
        'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    _tokenExpiresAt = DateTime.now().add(const Duration(hours: 1));

    // Create and return mock user
    _currentUser = User(
      id: 'f12345',
      email: email,
      fullName: 'John Doe',
      phone: '+256712345678',
      district: 'Kampala',
      village: 'Nakawa',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _currentUser!;
  }

  // Refresh token
  Future<void> refreshToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    // Update mock tokens
    _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    _refreshToken =
        'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    _tokenExpiresAt = DateTime.now().add(const Duration(hours: 1));
  }

  // Logout user
  Future<void> signOut() async {
    _token = null;
    _refreshToken = null;
    _tokenExpiresAt = null;
    _currentUser = null;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  // Stream to listen for auth changes
  Stream<User?> get user {
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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Update mock user
    _currentUser = _currentUser!.copyWith(
      fullName: displayName,
      phone: phone,
      district: district,
      village: village,
      profileImageUrl: photoURL ?? _currentUser!.profileImageUrl,
      updatedAt: DateTime.now(),
    );

    return _currentUser!;
  }

  // Update password
  Future<void> updatePassword(String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String district,
    required String village,
  }) async {
    return register(
      email: email,
      password: password,
      fullName: displayName,
      phone: phone,
      district: district,
      village: village,
    );
  }

  @override
  void dispose() {
    // No cleanup needed for mock service
  }
}
