import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm/presentation/providers/auth_provider.dart';
import 'package:farm/presentation/providers/farm_provider.dart';
import 'package:farm/presentation/providers/theme_provider.dart';
import 'package:farm/presentation/providers/season_provider.dart';
import 'package:farm/presentation/providers/notification_provider.dart';
import 'package:farm/core/services/notification_service.dart';
import 'package:farm/routes.dart';
import 'package:farm/constants/app_colors.dart';
import 'package:farm/presentation/screens/splash/splash_screen.dart';
import 'package:farm/core/services/api_service.dart';
import 'package:farm/constants/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(baseUrl: AppConfig.apiBaseUrl);
    final notificationService = NotificationService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
              ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
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
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
