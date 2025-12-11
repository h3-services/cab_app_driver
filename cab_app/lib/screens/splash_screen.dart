import 'package:flutter/material.dart';
import '../services/auth_middleware.dart';
import '../theme/colors.dart';
import 'login_screen.dart';
import 'driver_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final AuthMiddleware _authMiddleware = AuthMiddleware();
  
  String _status = 'Initializing...';
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _logoController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _status = 'Checking authentication...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    final authResult = await _authMiddleware.checkAuthStatus();
    
    if (authResult['isAuthenticated'] == true) {
      setState(() => _status = 'Welcome back!');
      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToHome();
    } else {
      if (authResult['error'] != null) {
        setState(() => _status = authResult['error']);
        await Future.delayed(const Duration(seconds: 2));
      }
      setState(() => _status = 'Redirecting to login...');
      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToLogin();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.mainBg, Colors.white.withOpacity(0.9)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Image.asset(
                      'assets/images/loho.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_taxi,
                          size: 120,
                          color: AppColors.accentText,
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Cab Driver',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.iconBg),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}