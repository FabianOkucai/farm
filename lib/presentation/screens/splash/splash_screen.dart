import 'package:flutter/material.dart';
import 'dart:async';
import '../../../constants/assets_path.dart';
import '../../../core/utils/navigation_helper.dart';
import '../auth/login_screen.dart';
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

    if (mounted) {
      NavigationHelper.navigateToReplacement(context, const LoginScreen());
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
          child: Image.asset(
            AssetPaths.logo,
            width: 700,
            height: 700,
          ),
        ),
      ),
    );
  }
}
