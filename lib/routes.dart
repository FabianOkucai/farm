import 'package:flutter/material.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/add_farm/add_farm_screen.dart';
import 'presentation/screens/farm_details/farm_details_screen.dart';
import 'presentation/screens/farm_notes/farm_notes_screen.dart';
import 'presentation/screens/seasons/seasons_screen.dart';
import 'presentation/screens/profile/profile_settings_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/add-farm':
        return MaterialPageRoute(builder: (_) => const AddFarmScreen());
      case '/farm-details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => FarmDetailsScreen(farmId: args['farmId'] as String),
        );
      case '/farm-notes':
        return MaterialPageRoute(builder: (_) => const FarmNotesScreen());
      case '/seasons':
        return MaterialPageRoute(builder: (_) => const SeasonsScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileSettingsScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
