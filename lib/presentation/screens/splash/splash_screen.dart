import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../constants/assets_path.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/local_storage.dart';
import '../../providers/farm_provider.dart';
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

// UPDATE: Replace the _navigateToNextScreen method in SplashScreen
  Future<void> _navigateToNextScreen() async {
    // Show splash for minimum time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check for uuid in local storage
      final localStorage = await LocalStorage.init();
      final uuid = localStorage.getUuid();

      debugPrint('🔍 Checking UUID: ${uuid != null ? "${uuid.substring(0, 8)}..." : "none"}');

      if (uuid != null && uuid.isNotEmpty) {
        debugPrint('✅ UUID found - loading user farms...');

        // Load farms before navigating to dashboard
        final farmProvider = Provider.of<FarmProvider>(context, listen: false);

        try {
          await farmProvider.loadFarms();
          debugPrint('✅ Farms loaded successfully');
        } catch (e) {
          debugPrint('⚠️ Failed to load farms, continuing to dashboard: $e');
          // Continue to dashboard even if farm loading fails
        }

        if (mounted) {
          NavigationHelper.navigateToReplacement(context, const DashboardScreen());
        }
      } else {
        debugPrint('❌ No UUID found - navigating to add farm');

        if (mounted) {
          NavigationHelper.navigateToReplacement(context, const AddFarmScreen());
        }
      }
    } catch (e) {
      debugPrint('❌ Error during navigation: $e');

      if (mounted) {
        // Fallback to add farm screen
        NavigationHelper.navigateToReplacement(context, const AddFarmScreen());
      }
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
