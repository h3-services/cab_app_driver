import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

/// A service class to handle network-related checks.
class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// Checks if the device is connected to a network (Wi-Fi, Mobile, or Ethernet).
  ///
  /// Returns `true` if a connection is available, otherwise `false`.
  Future<bool> isNetworkConnected() async {
    final ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();
        
    // Check if connected to any network type
    return connectivityResult != ConnectivityResult.none;
  }

  /// Tests actual internet connectivity and speed
  Future<Map<String, dynamic>> testInternetSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 10));
      
      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;
      
      if (response.statusCode == 200) {
        String speedStatus;
        if (responseTime < 500) {
          speedStatus = 'Fast';
        } else if (responseTime < 1500) {
          speedStatus = 'Good';
        } else {
          speedStatus = 'Slow';
        }
        
        return {
          'connected': true,
          'speed': speedStatus,
          'responseTime': responseTime,
        };
      }
    } catch (e) {
      // No internet connection
    }
    
    return {
      'connected': false,
      'speed': 'No Connection',
      'responseTime': 0,
    };
  }
}