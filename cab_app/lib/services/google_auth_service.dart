import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Check if already signed in
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        return {
          'success': true,
          'id': currentUser.uid,
          'name': currentUser.displayName ?? 'Firebase User',
          'email': currentUser.email ?? '',
        };
      }

      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Try Google Sign-In with timeout
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );
      
      if (googleUser == null) {
        return {'success': false, 'error': 'Sign-in cancelled or timed out'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return {'success': false, 'error': 'Failed to get authentication tokens'};
      }
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        return {
          'success': true,
          'id': user.uid,
          'name': user.displayName ?? googleUser.displayName ?? 'Firebase User',
          'email': user.email ?? googleUser.email ?? '',
        };
      }
      
      return {'success': false, 'error': 'No user data received'};
    } catch (e) {
      print('Google Sign-In Error: $e');
      
      // Specific error handling
      String errorMessage = 'Authentication failed';
      if (e.toString().contains('PlatformException')) {
        errorMessage = 'Google Play Services error. Please update Google Play Services.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage = 'Configuration error. Please contact support.';
      }
      
      // Check if Firebase Auth worked despite error
      final User? user = _auth.currentUser;
      if (user != null) {
        return {
          'success': true,
          'id': user.uid,
          'name': user.displayName ?? 'Firebase User',
          'email': user.email ?? '',
        };
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Sign out error: $e');
    }
  }
  
  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  bool get isSignedIn => _auth.currentUser != null;
}