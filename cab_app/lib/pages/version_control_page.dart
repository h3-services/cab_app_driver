import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/version_control_service.dart';
import '../services/network_service.dart';
import 'network_page.dart';
import 'home_page.dart';
import '../theme/colors.dart';

void main() {
  runApp(MaterialApp(
    home: const VersionControlPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class VersionControlPage extends StatefulWidget {
  const VersionControlPage({super.key});

  @override
  State<VersionControlPage> createState() => _VersionControlPageState();
}

class _VersionControlPageState extends State<VersionControlPage> {
  final VersionControlService _versionService = VersionControlService(
    minimumRequiredVersion: '1.0.0',
    apiEndpoint: 'https://h3-services.github.io/versionController/cab_app_version.json',
  );
  String _status = 'Checking version...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkVersion();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NetworkPage()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _checkVersion() async {
    setState(() => _isLoading = true);
    await _versionService.initialize();
    setState(() {
      _isLoading = false;
      if (_versionService.isUpdateAvailable()) {
        _status = 'Update available: ${_versionService.getNewVersion()}';
      } else {
        _status = 'Current version: ${_versionService.getCurrentVersion()}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Version Control'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            Text(
              _status,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Cab Driver')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.iconBg,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}