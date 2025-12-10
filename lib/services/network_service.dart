import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../pages/network_error_page.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      // First check connectivity status
      final connectivityResults = await _connectivity.checkConnectivity();
      
      // If no connectivity reported, return false immediately
      if (connectivityResults.isEmpty || 
          connectivityResults.every((result) => result == ConnectivityResult.none)) {
        return false;
      }

      // Test actual internet connection
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 2),
      );
      return result.isNotEmpty;
    } catch (e) {
      // Any error means no connection
      return false;
    }
  }

  /// Check network and navigate to error page if no connection
  static Future<bool> checkNetworkAndNavigate(BuildContext context, {VoidCallback? onRetry}) async {
    final hasConnection = await NetworkService().hasInternetConnection();
    print('Network check result: $hasConnection'); // Debug print
    
    if (!hasConnection) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NetworkErrorPage(
            onRetry: () {
              Navigator.of(context).pop(); // Go back to login
              if (onRetry != null) onRetry();
            },
          ),
        ),
      );
      return false;
    }
    return true;
  }

  /// Stream to listen for connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;
}