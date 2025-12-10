import 'package:flutter/material.dart';
import 'network_service.dart';
import '../pages/network_error_page.dart';

class NetworkHelper {
  /// Check network and navigate to error page if no connection
  static Future<bool> checkNetworkAndNavigate(BuildContext context, {VoidCallback? onRetry}) async {
    final hasConnection = await NetworkService().hasInternetConnection();
    
    if (!hasConnection) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NetworkErrorPage(onRetry: onRetry),
        ),
      );
      return false;
    }
    return true;
  }

  /// Show network error dialog
  static void showNetworkErrorDialog(BuildContext context, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final hasConnection = await NetworkService().hasInternetConnection();
              if (hasConnection && onRetry != null) {
                onRetry();
              } else if (!hasConnection) {
                showNetworkErrorDialog(context, onRetry: onRetry);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}