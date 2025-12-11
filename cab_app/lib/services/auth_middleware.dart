import 'package:firebase_auth/firebase_auth.dart';
import '../models/driver.dart';
import 'role_auth_service.dart';
import 'local_storage_service.dart';

class AuthMiddleware {
  static final AuthMiddleware _instance = AuthMiddleware._internal();
  factory AuthMiddleware() => _instance;
  AuthMiddleware._internal();

  final RoleAuthService _roleAuthService = RoleAuthService();
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<Map<String, dynamic>> checkAuthStatus() async {
    try {
      // Check if user is logged in locally
      final isLoggedIn = await _localStorageService.isLoggedIn();
      if (!isLoggedIn) {
        return {
          'isAuthenticated': false,
          'shouldRedirectToLogin': true,
        };
      }

      // Check Firebase Auth status
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await _localStorageService.logout();
        return {
          'isAuthenticated': false,
          'shouldRedirectToLogin': true,
        };
      }

      // Get current driver profile
      final driver = await _roleAuthService.getCurrentDriverProfile();
      if (driver == null) {
        await _localStorageService.logout();
        await FirebaseAuth.instance.signOut();
        return {
          'isAuthenticated': false,
          'shouldRedirectToLogin': true,
          'error': 'Driver profile not found',
        };
      }

      // Validate role and status
      if (driver.role != 'driver') {
        await _localStorageService.logout();
        await FirebaseAuth.instance.signOut();
        return {
          'isAuthenticated': false,
          'shouldRedirectToLogin': true,
          'error': 'Invalid role for this application',
        };
      }

      if (driver.status == 'blocked' || driver.status == 'suspended') {
        await _localStorageService.logout();
        await FirebaseAuth.instance.signOut();
        return {
          'isAuthenticated': false,
          'shouldRedirectToLogin': true,
          'error': 'Account is ${driver.status}',
        };
      }

      // Update local storage with latest driver data
      await _localStorageService.saveDriver(driver);

      return {
        'isAuthenticated': true,
        'driver': driver,
        'shouldRedirectToLogin': false,
      };
    } catch (e) {
      await _localStorageService.logout();
      return {
        'isAuthenticated': false,
        'shouldRedirectToLogin': true,
        'error': 'Authentication check failed: ${e.toString()}',
      };
    }
  }

  Future<void> signOut() async {
    await _localStorageService.logout();
    await _roleAuthService.signOut();
  }
}