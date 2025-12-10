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
  String _status = 'Disconnected';
  String _speedInfo = '';
  bool _isConnected = false;
  bool _isLoading = true;
  bool _wasDisconnected = true;

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
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        // Only check when connection is detected
        final speedTest = await _networkService.testInternetSpeed();
        if (mounted) {
          setState(() {
            _isConnected = speedTest['connected'];
            _status = speedTest['connected'] ? 'Connected' : 'Disconnected';
            _speedInfo = speedTest['connected'] 
                ? '${speedTest['speed']} (${speedTest['responseTime']}ms)'
                : '';
          });
          
          // Only navigate when internet comes back online and was previously disconnected
          if (speedTest['connected'] && _wasDisconnected) {
            _wasDisconnected = false;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        }
      } else {
        // Connection lost
        if (mounted) {
          setState(() {
            _isConnected = false;
            _status = 'Disconnected';
            _speedInfo = '';
            _wasDisconnected = true;
          });
        }
      }
    });
  }

  Future<void> _checkNetwork() async {
    setState(() => _isLoading = true);
    final speedTest = await _networkService.testInternetSpeed();
    setState(() {
      _isLoading = false;
      _isConnected = speedTest['connected'];
      _status = speedTest['connected'] ? 'Connected' : 'Disconnected';
      _speedInfo = speedTest['connected'] 
          ? '${speedTest['speed']} (${speedTest['responseTime']}ms)'
          : '';
    });
    
    if (speedTest['connected']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              size: 80,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(_status, style: Theme.of(context).textTheme.headlineSmall),
            if (_speedInfo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Speed: $_speedInfo',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkNetwork,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}