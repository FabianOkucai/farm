// lib/main.dart
import 'package:farm/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm/presentation/providers/auth_provider.dart';
import 'package:farm/presentation/providers/farm_provider.dart';
import 'package:farm/presentation/providers/theme_provider.dart';
import 'package:farm/presentation/providers/season_provider.dart';
import 'package:farm/presentation/providers/notification_provider.dart';
import 'package:farm/core/services/notification_service.dart';
import 'package:farm/core/services/notification_generator.dart';
import 'package:farm/core/services/daily_checker_service.dart';
import 'package:farm/core/services/auth_service.dart';
import 'package:farm/core/utils/local_storage.dart';
import 'package:farm/routes.dart';
import 'package:farm/constants/app_colors.dart';
import 'package:farm/presentation/screens/splash/splash_screen.dart';
import 'package:farm/core/services/api_service.dart';
import 'package:farm/constants/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize core services
    final localStorage = await LocalStorage.init();

    // Initialize API services
    final apiService = ApiService(
      baseUrl: AppConfig.apiBaseUrl,
      localStorage: localStorage,
    );
    final authService = AuthService(baseUrl: AppConfig.apiBaseUrl);

    // Initialize notification services
    final notificationService = NotificationService();
    final notificationGenerator = NotificationGenerator(
      notificationService: notificationService,
      localStorage: localStorage,
    );
    final dailyCheckerService = DailyCheckerService(
      localStorage: localStorage,
      notificationGenerator: notificationGenerator,
    );

    runApp(
      MyApp(
        apiService: apiService,
        authService: authService,
        notificationService: notificationService,
        localStorage: localStorage,
        notificationGenerator: notificationGenerator,
        dailyCheckerService: dailyCheckerService,
      ),
    );
  } catch (e) {
    // Handle initialization errors
    debugPrint('Failed to initialize app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final AuthService authService;
  final NotificationService notificationService;
  final LocalStorage localStorage;
  final NotificationGenerator notificationGenerator;
  final DailyCheckerService dailyCheckerService;

  const MyApp({
    super.key,
    required this.apiService,
    required this.authService,
    required this.notificationService,
    required this.localStorage,
    required this.notificationGenerator,
    required this.dailyCheckerService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the auth service instance to AuthProvider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => FarmProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => SeasonProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create:
              (_) => NotificationProvider(
                notificationService: notificationService,
                notificationGenerator: notificationGenerator,
                dailyCheckerService: dailyCheckerService,
                localStorage: localStorage,
              ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return MaterialApp(
                title: 'Agape Farm App',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primaryColor: AppColors.primaryGreen,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primaryGreen,
                    primary: AppColors.primaryGreen,
                    secondary: AppColors.secondaryGreen,
                  ),
                  fontFamily: 'Roboto',
                  useMaterial3: true,
                ),
                darkTheme: ThemeData.dark().copyWith(
                  primaryColor: AppColors.primaryGreen,
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primaryGreen,
                    secondary: AppColors.secondaryGreen,
                  ),
                  useMaterial3: true,
                ),
                themeMode: themeProvider.themeMode,
                initialRoute: '/',
                onGenerateRoute: AppRouter.generateRoute,
                home: _getInitialScreen(authProvider),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getInitialScreen(AuthProvider authProvider) {
    if (!authProvider.isInitialized) {
      return const SplashScreen();
    }

    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    }

    return const SplashScreen();
  }
}

// Error app for initialization failures
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
