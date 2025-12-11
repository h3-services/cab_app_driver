import 'package:firebase_auth/firebase_auth.dart';

class EmailAuthService {
  static final EmailAuthService _instance = EmailAuthService._internal();
  factory EmailAuthService() => _instance;
  EmailAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        return {
          'success': true,
          'id': user.uid,
          'name': user.displayName ?? 'Driver User',
          'email': user.email ?? email,
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
        'error': 'Authentication failed: $e',
      };
    }
  }

  Future<Map<String, dynamic>> registerWithEmail(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        return {
          'success': true,
          'id': user.uid,
          'name': name,
          'email': user.email ?? email,
        };
      }
      
      return {
        'success': false,
        'error': 'Registration failed',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration failed: $e',
      };
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent to $email',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Password reset failed: ${e.message}';
      }
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Password reset failed: $e',
      };
    }
  }
}