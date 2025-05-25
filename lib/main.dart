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
import 'package:farm/core/utils/local_storage.dart';
import 'package:farm/routes.dart';
import 'package:farm/constants/app_colors.dart';
import 'package:farm/presentation/screens/splash/splash_screen.dart';
import 'package:farm/core/services/api_service.dart';
import 'package:farm/constants/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final apiService = ApiService(baseUrl: AppConfig.apiBaseUrl);
  final notificationService = NotificationService();
  final localStorage = await LocalStorage.init();
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
      notificationService: notificationService,
      localStorage: localStorage,
      notificationGenerator: notificationGenerator,
      dailyCheckerService: dailyCheckerService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final NotificationService notificationService;
  final LocalStorage localStorage;
  final NotificationGenerator notificationGenerator;
  final DailyCheckerService dailyCheckerService;

  const MyApp({
    super.key,
    required this.apiService,
    required this.notificationService,
    required this.localStorage,
    required this.notificationGenerator,
    required this.dailyCheckerService,
  });

  @override
  Widget build(BuildContext context) {
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
                notificationGenerator: notificationGenerator,
                dailyCheckerService: dailyCheckerService,
                localStorage: localStorage,
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
