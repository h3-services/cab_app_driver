import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/driver_email_service.dart';
import '../services/local_storage_service.dart';
import '../models/driver.dart';
import '../theme/colors.dart';
import 'driver_home_screen.dart';
import 'profile_update_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final _driverEmailService = DriverEmailService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      
      if (account != null) {
        print('Google Sign-In successful: ${account.email}');
        final driver = await _driverEmailService.getDriverByEmail(account.email);
        print('Driver found: ${driver != null}');
        
        if (driver != null) {
          print('Driver status: ${driver.status}');
          if (driver.status == 'blocked' || driver.status == 'suspended') {
            _showError('Account is ${driver.status}. Contact support.');
            return;
          }
          
          print('Saving driver data...');
          await LocalStorageService.saveDriverData(driver);
          print('Driver data saved, navigating to home...');
          
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
              (route) => false,
            );
            print('Navigation completed');
          }
        } else {
          print('Driver not found in database, navigating to profile update');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileUpdateScreen(
                  driver: Driver(
                    id: '',
                    name: account.displayName ?? '',
                    email: account.email,
                    phone: '',
                    licenseNumber: '',
                    aadhaarNumber: '',
                    vehicleType: '',
                    vehicleNumber: '',
                    vehicleModel: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ),
              ),
            );
          }
        }
      } else {
        print('Google sign-in cancelled');
        _showError('Google sign-in cancelled');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/loho.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_taxi,
                      size: 80,
                      color: AppColors.accentText,
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Cab Driver Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to start your journey',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 40),
              
              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 3,
                    side: BorderSide(color: AppColors.grayText.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.g_mobiledata,
                                  size: 24,
                                  color: Colors.black87,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}