import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/driver.dart';

class RoleAuthService {
  static final RoleAuthService _instance = RoleAuthService._internal();
  factory RoleAuthService() => _instance;
  RoleAuthService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> authenticateWithRole(String email) async {
    try {
      // Check if user exists in Firestore by email
      final querySnapshot = await _firestore
          .collection('drivers')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'error': 'User not found. Please contact admin for registration.',
        };
      }

      final driverDoc = querySnapshot.docs.first;
      final driverData = driverDoc.data();
      final driver = Driver.fromMap({...driverData, 'id': driverDoc.id});

      // Validate role
      if (driver.role != 'driver') {
        return {
          'success': false,
          'error': 'Access denied. Invalid role for this application.',
        };
      }

      // Check account status
      if (driver.status == 'blocked' || driver.status == 'suspended') {
        return {
          'success': false,
          'error': 'Account is ${driver.status}. Please contact support.',
        };
      }

      return {
        'success': true,
        'driver': driver,
        'message': 'Authentication successful',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Authentication failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> signInWithEmailAndRole(String email, String password) async {
    try {
      // First check role-based authentication
      final roleCheck = await authenticateWithRole(email);
      if (!roleCheck['success']) {
        return roleCheck;
      }

      // If role check passes, proceed with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        return {
          'success': true,
          'driver': roleCheck['driver'],
          'user': userCredential.user,
          'message': 'Login successful',
        };
      }

      return {
        'success': false,
        'error': 'Authentication failed',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'User account has been disabled';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
      }
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Authentication failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> signInWithGoogleAndRole() async {
    try {
      // Get current Firebase user (assuming Google sign-in already happened)
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return {
          'success': false,
          'error': 'No authenticated user found',
        };
      }

      // Check role-based authentication
      final roleCheck = await authenticateWithRole(user.email!);
      if (!roleCheck['success']) {
        // Sign out if role check fails
        await _auth.signOut();
        return roleCheck;
      }

      return {
        'success': true,
        'driver': roleCheck['driver'],
        'user': user,
        'message': 'Login successful',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Authentication failed: ${e.toString()}',
      };
    }
  }

  Future<Driver?> getCurrentDriverProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return null;

      final querySnapshot = await _firestore
          .collection('drivers')
          .where('email', isEqualTo: user.email!.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final driverDoc = querySnapshot.docs.first;
      final driverData = driverDoc.data();
      return Driver.fromMap({...driverData, 'id': driverDoc.id});
    } catch (e) {
      print('Error getting current driver profile: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get isSignedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
}