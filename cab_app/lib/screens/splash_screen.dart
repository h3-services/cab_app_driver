import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../services/version_control_service.dart';
import '../theme/colors.dart';
import 'login_screen.dart';
import '../pages/network_page.dart';
import '../pages/update_page.dart';
import '../pages/home_page.dart';

void main() {
  runApp(MaterialApp(
    home: const SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final NetworkService _networkService = NetworkService();
  final VersionControlService _versionService = VersionControlService(
    minimumRequiredVersion: '1.0.0',
    apiEndpoint: 'https://h3-services.github.io/versionController/cab_app_version.json',
  );
  
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
    
    setState(() => _status = 'Checking network...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    final isConnected = await _networkService.isNetworkConnected();
    
    if (!isConnected) {
      _navigateToNetworkPage();
      return;
    }
    
    setState(() => _status = 'Checking version...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _versionService.initialize();
    
    if (_versionService.isUpdateAvailable()) {
      _navigateToUpdatePage();
      return;
    }
    
    setState(() => _status = 'Ready to go!');
    await Future.delayed(const Duration(milliseconds: 800));
    
    _navigateToHome();
  }

  void _navigateToNetworkPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NetworkPage()),
    );
  }

  void _navigateToUpdatePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UpdatePage()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Cab Driver')),
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
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo1.png',
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