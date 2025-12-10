import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_service.dart';
import '../pages/network_page.dart';

class GlobalNetworkManager {
  static final GlobalNetworkManager _instance = GlobalNetworkManager._internal();
  factory GlobalNetworkManager() => _instance;
  GlobalNetworkManager._internal();

  final NetworkService _networkService = NetworkService();
  BuildContext? _currentContext;

  void initialize(BuildContext context) {
    _currentContext = context;
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      final isConnected = await _networkService.isNetworkConnected();
      
      if (!isConnected && _currentContext != null) {
        final currentRoute = ModalRoute.of(_currentContext!)?.settings.name;
        if (currentRoute != '/network') {
          Navigator.of(_currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const NetworkPage(),
              settings: const RouteSettings(name: '/network'),
            ),
            (route) => false,
          );
        }
      }
    });
  }

  void updateContext(BuildContext context) {
    _currentContext = context;
  }
}