import 'dart:async';
import '../models/user.dart';

abstract class BaseAuthService {
  String? get token;
  bool get isAuthenticated;

  Future<void> init();

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String district,
    required String village,
  });

  Future<User> signIn({
    required String email,
    required String password,
  });

  Future<void> refreshToken();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Stream<User?> get user;

  Future<User> updateProfile({
    required String displayName,
    required String phone,
    required String district,
    required String village,
    String? photoURL,
  });

  Future<void> updatePassword(String password);
  Future<void> resetPassword(String email);
}
