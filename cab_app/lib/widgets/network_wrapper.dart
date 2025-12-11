import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../pages/network_page.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;
  
  const NetworkWrapper({super.key, required this.child});

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  bool _hasNetwork = true;
  Timer? _networkTimer;

  @override
  void initState() {
    super.initState();
    _checkInitialNetwork();
    _startNetworkMonitoring();
  }

  void _checkInitialNetwork() async {
    bool hasNetwork = await _checkNetwork();
    setState(() {
      _hasNetwork = hasNetwork;
    });
  }

  void _startNetworkMonitoring() {
    _networkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      bool hasNetwork = await _checkNetwork();
      if (mounted && _hasNetwork != hasNetwork) {
        setState(() {
          _hasNetwork = hasNetwork;
        });
        print('Network status changed: $hasNetwork');
      }
    });
  }

  Future<bool> _checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasNetwork) {
      return const NetworkPage();
    }
    return widget.child;
  }
}