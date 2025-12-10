import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network_service.dart';
import 'home_page.dart';
import '../theme/colors.dart';

void main() {
  runApp(MaterialApp(
    home: const NetworkPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> with TickerProviderStateMixin {
  final NetworkService _networkService = NetworkService();
  String _status = 'No Internet';
  bool _isConnected = false;
  bool _isLoading = true;
  bool _isConnecting = false;
  late AnimationController _pulseController;
  late AnimationController _connectController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _connectController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _connectController, curve: Curves.elasticOut),
    );
    _checkNetwork();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _checkNetwork();
    });
  }

  Future<void> _checkNetwork() async {
    setState(() => _isLoading = true);
    final isConnected = await _networkService.isNetworkConnected();
    
    if (isConnected) {
      if (!_isConnected && mounted) {
        setState(() {
          _isLoading = false;
          _isConnecting = true;
          _status = 'Connecting...';
        });
        
        _connectController.forward();
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          setState(() {
            _isConnected = true;
            _isConnecting = false;
            _status = 'Connected!';
          });
          
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Cab Driver')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _isConnected = false;
        _isConnecting = false;
        _status = 'No Internet';
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.iconBg,
              AppColors.iconBg.withOpacity(0.8),
              AppColors.mainBg,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                )
              else if (_isConnecting)
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        children: [
                          Icon(
                            Icons.wifi,
                            size: 150,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 20),
                          CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isConnected 
                    ? Icon(
                        Icons.wifi,
                        key: ValueKey(_isConnected),
                        size: 150,
                        color: Colors.green,
                      )
                    : Image.asset(
                        'assets/images/logo1.png',
                        key: ValueKey(_isConnected),
                        width: 150,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.wifi_off,
                            size: 150,
                            color: Colors.red,
                          );
                        },
                      ),
                ),
              const SizedBox(height: 40),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              if (!_isConnected && !_isLoading)
                ElevatedButton(
                  onPressed: _checkNetwork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.iconBg,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}