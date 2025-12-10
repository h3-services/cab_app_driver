import 'package:flutter/material.dart';
import '../pages/network_page.dart';
import '../screens/login_screen.dart';
import '../services/network_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _networkStatus = 'Checking network...';

  @override
  void initState() {
    super.initState();
    _checkNetworkAndNavigate();
  }

  Future<void> _checkNetworkAndNavigate() async {
    final networkService = NetworkService();
    final isConnected = await networkService.isNetworkConnected();
    
    setState(() {
      _networkStatus = isConnected ? 'Connected' : 'Offline';
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      if (isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NetworkPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_taxi,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Cab Booking',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _networkStatus,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}