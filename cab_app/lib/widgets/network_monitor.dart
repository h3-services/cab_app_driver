import 'package:flutter/material.dart';
import 'dart:async';
import '../services/network_service.dart';
import '../pages/network_page.dart';

class NetworkMonitor extends StatefulWidget {
  final Widget child;
  
  const NetworkMonitor({super.key, required this.child});

  @override
  State<NetworkMonitor> createState() => _NetworkMonitorState();
}

class _NetworkMonitorState extends State<NetworkMonitor> {
  final NetworkService _networkService = NetworkService();
  StreamSubscription<bool>? _networkSubscription;
  bool _showNetworkPage = false;

  @override
  void initState() {
    super.initState();
    _initializeNetworkService();
  }

  void _initializeNetworkService() {
    _networkService.initialize(
      showNoInternetPage: _showNoInternetPage,
      resumeApp: _resumeApp,
    );
    
    _networkSubscription = _networkService.networkStream.listen((isConnected) {
      // Stream listener for additional handling if needed
    });
  }

  void _showNoInternetPage() {
    if (mounted) {
      setState(() {
        _showNetworkPage = true;
      });
    }
  }

  void _resumeApp() {
    if (mounted) {
      setState(() {
        _showNetworkPage = false;
      });
    }
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showNetworkPage) {
      return const NetworkPage();
    }
    return widget.child;
  }
}