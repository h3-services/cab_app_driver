import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../pages/network_error_page.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;
  
  const NetworkWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  bool _hasConnection = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectivityChanges();
  }

  void _checkInitialConnection() async {
    final hasConnection = await NetworkService().hasInternetConnection();
    if (mounted) {
      setState(() {
        _hasConnection = hasConnection;
        _isChecking = false;
      });
    }
  }

  void _listenToConnectivityChanges() {
    NetworkService().connectivityStream.listen((_) async {
      final hasConnection = await NetworkService().hasInternetConnection();
      if (mounted && _hasConnection != hasConnection) {
        setState(() {
          _hasConnection = hasConnection;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasConnection) {
      return NetworkErrorPage(
        onRetry: () {
          _checkInitialConnection();
        },
      );
    }

    return widget.child;
  }
}