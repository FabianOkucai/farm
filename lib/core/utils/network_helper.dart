// lib/core/utils/network_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkHelper {
  static Future<bool> hasInternetConnection() async {
    try {
      debugPrint('🌐 Checking internet connectivity...');

      // Try to reach Google's DNS
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('✅ Internet connection available');
        return true;
      } else {
        debugPrint('❌ No internet connection');
        return false;
      }
    } on SocketException catch (e) {
      debugPrint('🔌 Socket exception during connectivity check: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      return false;
    }
  }

  static Future<bool> canReachApi(String baseUrl) async {
    try {
      debugPrint('🎯 Testing Laravel API reachability for: $baseUrl');

      // For Laravel, try a simple GET to see if server is responding
      // Laravel might return 404 for unknown routes, but that means server is reachable
      final response = await http.get(
        Uri.parse(baseUrl), // Test the base URL
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest', // Laravel expects this
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('📡 Laravel API response status: ${response.statusCode}');
      debugPrint('📄 Laravel API response body: ${response.body}');

      // For Laravel, even 404, 405, or 500 means the server is reachable
      // Only network errors (connection refused, timeout) mean unreachable
      if (response.statusCode >= 200 && response.statusCode < 600) {
        debugPrint('✅ Laravel server is reachable');
        return true;
      } else {
        debugPrint('❌ Laravel server returned unexpected status: ${response.statusCode}');
        return false;
      }
    } on SocketException catch (e) {
      debugPrint('🔌 Cannot reach Laravel server - Socket Exception: $e');
      debugPrint('💡 Make sure Laravel is running: php artisan serve');
      return false;
    } on http.ClientException catch (e) {
      debugPrint('🌐 Cannot reach Laravel server - Client Exception: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Error testing Laravel server reachability: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> diagnoseConnection(String baseUrl) async {
    debugPrint('🔍 Starting network diagnostics...');

    final hasInternet = await hasInternetConnection();
    final canReachApi = hasInternet ? await NetworkHelper.canReachApi(baseUrl) : false;

    final diagnosis = {
      'hasInternet': hasInternet,
      'canReachApi': canReachApi,
      'baseUrl': baseUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint('📊 Network diagnosis complete: $diagnosis');
    return diagnosis;
  }
}