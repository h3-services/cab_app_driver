import 'package:flutter/material.dart';
import 'dart:io';
import '../screens/login_screen.dart';
import '../theme/colors.dart';
import 'network_page.dart';
import 'update_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      await _checkConnections();
    }
  }

  _checkConnections() async {
    bool hasNetwork = await _checkNetwork();
    
    if (!hasNetwork) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NetworkPage()),
      );
      return;
    }
    
    if (await _needsUpdate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UpdatePage()),
      );
      return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<bool> _checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _needsUpdate() async {
    // Check version logic here
    return false; // Return true if update needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_taxi,
              size: 80,
              color: AppColors.iconBg,
            ),
            const SizedBox(height: 20),
            const Text(
              'Cab Driver',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}