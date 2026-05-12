import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    await Future.delayed(const Duration(seconds: 1));

    final hasSession = await TokenStorage.hasValidSession();

    if (!mounted) return;

    if (hasSession) {
      final role = await TokenStorage.getRole();

      if (!mounted) return;

      switch (role) {
        case 'FERMIER':
          Navigator.pushReplacementNamed(context, '/fermier');
          break;
        case 'VETERINAIRE':
          Navigator.pushReplacementNamed(context, '/veterinaire');
          break;
        case 'CONTROLEUR':
          Navigator.pushReplacementNamed(context, '/controleur');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/launcher_icon/icon.png',
              width: 100,
              height: 100,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.agriculture,
                size: 100,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "DZcheptel",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}