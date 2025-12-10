import 'package:connectivity_plus/connectivity_plus.dart';

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
    return connectivityResult == ConnectivityResult.mobile ||
           connectivityResult == ConnectivityResult.wifi ||
           connectivityResult == ConnectivityResult.ethernet;
  }
}