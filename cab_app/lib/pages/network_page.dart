import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network_service.dart';
import 'version_control_page.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final NetworkService _networkService = NetworkService();
  String _status = 'Checking network...';
  bool _isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNetwork();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VersionControlPage()),
        );
      }
    });
  }

  Future<void> _checkNetwork() async {
    setState(() => _isLoading = true);
    final isConnected = await _networkService.isNetworkConnected();
    setState(() {
      _isLoading = false;
      _isConnected = isConnected;
      _status = isConnected ? 'Connected' : 'Disconnected';
    });
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