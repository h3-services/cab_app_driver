import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../models/driver.dart';
import '../theme/colors.dart';
import 'personal_details_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _localStorageService = LocalStorageService();

  void _directLogin() async {
    // Create a dummy driver for testing
    final driver = Driver(
      id: 'driver_001',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+1234567890',
      licenseNumber: 'DL123456',
      aadhaarNumber: '1234-5678-9012',
      vehicleType: 'Sedan',
      vehicleNumber: 'ABC-1234',
      vehicleModel: 'Toyota Camry',
      status: 'approved',
      isAvailable: false,
      walletBalance: 1500.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _localStorageService.saveDriver(driver);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PersonalDetailsScreen(driver: driver)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/loho.png',
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.local_taxi,
                  size: 100,
                  color: AppColors.accentText,
                );
              },
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Cab Driver',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 50),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _directLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login as Driver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}