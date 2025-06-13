import 'package:flutter/material.dart';
import 'dart:async';
import '../../../constants/assets_path.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/local_storage.dart';
import '../dashboard/dashboard_screen.dart';
import '../add_farm/add_farm_screen.dart';
import '../../widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));

    // Check for uuid in local storage
    final localStorage = await LocalStorage.init();
    final uuid = localStorage.getString('uuid');

    if (!mounted) return;
    if (uuid != null && uuid.isNotEmpty) {
      // Navigate to Dashboard if uuid exists
      NavigationHelper.navigateToReplacement(context, const DashboardScreen());
    } else {
      // Navigate to Add Farm screen if uuid does not exist
      NavigationHelper.navigateToReplacement(context, const AddFarmScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: [
          Color(0xFF000900),
          Color(0xFF026A02),
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
        ],
        child: Center(
          child: Image.asset(AssetPaths.logo, width: 700, height: 700),
        ),
      ),
    );
  }
}
